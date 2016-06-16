#!/bin/bash
# Utilities for both OSX and Docker
set -e

# Get our own location on this filesystem
MULTIBUILD_DIR=$(dirname "${BASH_SOURCE[0]}")

function abspath {
    python -c "import os.path; print(os.path.abspath('$1'))"
}

function relpath {
    # Path of first input relative to second (or $PWD if not specified)
    python -c "import os.path; print(os.path.relpath('$1','${2:-$PWD}'))"
}

function get_root {
    abspath $MULTIBUILD_DIR/..
}

function lex_ver {
    # Echoes dot-separated version string padded with zeros
    # Thus:
    # 3.2.1 -> 003002001
    # 3     -> 003000000
    echo $1 | awk -F "." '{printf "%03d%03d%03d", $1, $2, $3}'
}

function is_function {
    set +e
    $(declare -Ff "$1") > /dev/null && echo true
    set -e
}

function clean_fix_source {
    git checkout $1
    git clean -fxd
    git reset --hard
    git submodule update --init --recursive
    if [ -n $(is_function "patch_source") ]; then patch_source; fi
}

function install_wheel {
    # Install test dependencies and built wheel
    # Pass any input flags to pip install steps
    # Depends on:
    #     MANYLINUX_URL
    #     WHEEL_SDIR
    #     TEST_DEPENDS  (optional)
    local wheelhouse=$(get_root)/$WHEEL_SDIR
    if [ -n "$TEST_DEPENDS" ]; then
        pip install --find-links $MANYLINUX_URL $@ $TEST_DEPENDS
    fi
    # Install compatible wheel
    pip install --find-links $MANYLINUX_URL $@ \
        $(python $MULTIBUILD_DIR/supported_wheels.py $wheelhouse/*.whl)
}

function install_run {
    # Depend on function `run_tests` defined in `config_funcs.sh`
    install_wheel
    # Configuration for this package
    source $(get_root)/config_funcs.sh
    mkdir tmp_for_test
    (cd tmp_for_test && run_tests)
}
