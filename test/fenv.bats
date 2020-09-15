#!/usr/bin/env bats
set -euo pipefail

function setup() {
    HTML_FILE="test/index.html"
    TEST_FILE="test/index.test"
    cp "$HTML_FILE" "$TEST_FILE"
}

@test "correctly replaces variables" {

    TEST_STR="<body><script id=\"fenv\">window.env = {REACT_APP_TEST: 'some text',};</script>"

    # use env -i to wipe out other environment variables
    env -i \
        REACT_APP_TEST="some text" \
        src/fenv.sh "$(pwd)/$TEST_FILE"

    grep "$TEST_STR" "$TEST_FILE"
}
