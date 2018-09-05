source tests/utils.sh

function pre_build {
    [ -n "$MB_PYTHON_VERSION" ] || ingest "MB_PYTHON_VERSION not defined"

    if [ -z "$IS_OSX" ] && [ "$MB_PYTHON_VERSION" != "$PYTHON_VERSION" ]; then
        ingest "\$MB_PYTHON_VERSION must be equal to \$PYTHON_VERSION"
    fi

    # Exit 1 if any test errors
    barf
}
