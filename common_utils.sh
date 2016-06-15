#!/bin/bash
# Utilities for both OSX and Docker
set -e

function abspath {
    python -c "import os.path; print(os.path.abspath('$1'))"
}

# Get our own location on this filesystem
MULTIBUILD_DIR=$(dirname "${BASH_SOURCE[0]}")
ROOT_DIR=$(abspath $MULTIBUILD_DIR/..)

function install_wheel {
    # Install test dependencies and built wheel
    # Pass any input flags to pip install steps
    # Depends on:
    #     MANYLINUX_URL
    #     WHEEL_SDIR
    #     TEST_DEPENDS  (optional)
    if [ -n "$TEST_DEPENDS" ]; then
        pip install --find-links $MANYLINUX_URL $@ $TEST_DEPENDS
    fi
    # Install compatible wheel
    pip install --find-links $MANYLINUX_URL $@ \
        $(python $MULTIBUILD_DIR/supported_wheels.py $ROOT_DIR/$WHEEL_SDIR/*.whl)
}

function install_run {
    local run_tests_script=${1:-$RUN_TESTS_SCRIPT}
    install_wheel
    mkdir tmp_for_test
    cd tmp_for_test
    source $ROOT_DIR/$run_tests_script
    cd ..
}
