# Test utilities
RET=${RET:-0}

function ingest {
    local msg="${1:-"no message"}"
    echo "Test failed: $msg"
    RET=1
}

function barf {
    [ "$RET" == 0 ] || exit 1
}

function local_author {
    # Run in git repository to set commit author
    git config user.email "my@noble.self"
    git config user.name "Noble Self"
}
