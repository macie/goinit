#!/bin/sh

beforeAll() {
    TEST_ROOT_DIR=$(mktemp -d -t 'goinit_testXXXXXX')
    MOCK_DIR=$(mktemp -d -t 'goinit_mockXXXXXX')

    USED_CMDS='hexdump printf'
    for MOCKED_CMD in $USED_CMDS; do
        echo '#!/bin/sh' >"${MOCK_DIR}/${MOCKED_CMD}"
        if type "$MOCKED_CMD" | grep -q 'builtin'; then
            echo 'builtin '"$MOCKED_CMD"' $@' >>"${MOCK_DIR}/${MOCKED_CMD}"
        else
            echo "$(command -v "$MOCKED_CMD")"' $@' >>"${MOCK_DIR}/${MOCKED_CMD}"
        fi
        chmod +x "${MOCK_DIR}/${MOCKED_CMD}"
    done
}

afterAll() {
    rm -r "${TEST_ROOT_DIR:-/tmp/goinit}" "${MOCK_DIR:-/tmp/goinit_mock}" 2>/dev/null
}

test_issue1() {
    echo | PATH="$MOCK_DIR" ./goinit "$TEST_ROOT_DIR" 2>/dev/null >&2
    test $? -eq 78  # EX_CONFIG
}
