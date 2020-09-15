#!/bin/bash
set -euo pipefail

REPLACE_MARK="<body>"

# Make sure we are in the directory of this script
cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1

# Parameter validation
FILE="${1:-}"
[[ -z "$FILE" ]] && echo "Please specify the html files" && exit 1
[[ ! -f "$FILE" ]] && echo "$FILE does not exist" && exit 1

# find all variables with REACT_APP_ prefix
# shellcheck disable=SC2016
IFS=$'\r\n' GLOBIGNORE='*' command eval 'VARS=($(env | grep "^REACT_APP_" || echo ""))'

# generate JSON object
JSON_OBJECT=$(
    printf "{"

    # iterate through entries
    for i in "${VARS[@]}"; do
        KEY="${i%=*}"

        # resolve enviromment variable
        VAL=${!KEY:-}

        # skip if empty
        [[ -z "$VAL" ]] && continue

        printf "%s: '%s'," "$KEY" "$VAL"
    done
    printf "}"
)

# enclose it into script tag
SCRIPT_TAG=$(
    printf '<script id="fenv">'
    printf 'window.env = %s;' "$JSON_OBJECT"
    printf '</script>'
)

REPLACEMENT=$(
    printf '%s' "$REPLACE_MARK"
    printf '%s' "$SCRIPT_TAG"
)

# replace opening body tag with it
awk \
    -v REPLACE_MARK="$REPLACE_MARK" \
    -v REPLACEMENT="$REPLACEMENT" \
    '{ gsub(REPLACE_MARK, REPLACEMENT); print }' \
    "$FILE" >"$FILE.temp"

mv "$FILE.temp" "$FILE"

# do we have additional parameters?
# replace execution with that (for docker usage)

if [[ "$#" -ge 2 ]]; then
    shift
    exec "$@"
fi
