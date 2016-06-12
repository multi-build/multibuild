#!/bin/bash
# Update submodules
git submodule update --init --recursive

WHEELHOUSE=$PWD/wheelhouse

MULTIBUILD_DIR=$(dirname "${BASH_SOURCE[0]}")

if [ ! -d "$WHEELHOUSE" ]; then mkdir $WHEELHOUSE; fi
if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    source $MULTIBUILD_DIR/travis_osx_steps.sh
else
    source $MULTIBUILD_DIR/travis_linux_steps.sh
fi

if [ -z "$REPO_DIR$PKG_SPEC" ]; then
    echo "Must specify REPO_DIR or PKG_SPEC"
    exit 1
fi

function install_wheel {
    if [ -n "$TEST_DEPENDS" ]; then pip install $TEST_DEPENDS; fi
    pip install $(python $MULTIBUILD_DIR/supported_wheels.py $WHEELHOUSE/*.whl)
}
