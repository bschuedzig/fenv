#!/bin/bash
set -euo pipefail

CID_FILE="/tmp/fenv_test.cid"

rm "$CID_FILE" 2>/dev/null || :

cp ../src/fenv.sh .

docker build -t fenv .

docker run \
    --rm \
    -d \
    -p 18000:80 \
    -e REACT_APP_TEST='something' \
    --cidfile "$CID_FILE" \
    fenv

CID="$(cat $CID_FILE)"

sleep 2

CONTENT="$(curl -s http://localhost:18000/)"

docker kill "$CID"

if [[ "$CONTENT" == *"<script id=\"fenv\">window.env = {REACT_APP_TEST: 'something',};</script>"* ]]; then

    echo "Found:"
    echo "$CONTENT"
else
    echo "Fuck"
    exit 1
fi
