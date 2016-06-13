#!/bin/bash
# Update submodules
git submodule update --init --recursive

WHEELHOUSE=$PWD/wheelhouse
MULTIBUILD_DIR=$(dirname "${BASH_SOURCE[0]}")
MANYLINUX_URL=${MANYLINUX_URL:-https://nipy.bic.berkeley.edu/manylinux}

if [ ! -d "$WHEELHOUSE" ]; then mkdir $WHEELHOUSE; fi
if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    source $MULTIBUILD_DIR/travis_osx_steps.sh
else
    source $MULTIBUILD_DIR/travis_linux_steps.sh
fi

# Specify REPO_DIR to build from directory in this repository.
# Specify PKG_SPEC to build from pip requirement (e.g numpy==1.7.1)
# PKG_SPEC is hardly tested, please let us know of bugs.
if [ -z "$REPO_DIR$PKG_SPEC" ]; then
    echo "Must specify REPO_DIR or PKG_SPEC"
    exit 1
fi

function install_wheel {
    # Install test dependencies and built wheel
    # Pass any input flags to pip install steps
    # Depends on:
    #     MANYLINUX_URL
    #     WHEELHOUSE
    #     TEST_DEPENDS  (optional)
    if [ -n "$TEST_DEPENDS" ]; then
        pip install --find-links $MANYLINUX_URL $@ $TEST_DEPENDS
    fi
    # Install compatible wheel
    pip install --find-links $MANYLINUX_URL $@ \
        $(python $MULTIBUILD_DIR/supported_wheels.py $WHEELHOUSE/*.whl)
}
