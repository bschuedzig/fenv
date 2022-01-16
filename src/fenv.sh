#!/bin/bash
set -euo pipefail

TARGET_FILE="/usr/share/nginx/html/index.html"

if [[ -n "${1:-}" ]]; then
    TARGET_FILE="$1"
    if [[ ! -f "$TARGET_FILE" ]]; then
        echo "Cannot find file $TARGET_FILE"
        exit 2
    fi
fi

# The mark will be replaced with MARK + <script tag>
REPLACE_MARK="<body>"

[[ ! -f "$TARGET_FILE" ]] && echo "$TARGET_FILE does not exist" && exit 1

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
    "$TARGET_FILE" >"$TARGET_FILE.temp"

mv "$TARGET_FILE.temp" "$TARGET_FILE"
