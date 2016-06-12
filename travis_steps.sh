#!/bin/bash
# Update submodules
git submodule update --init --recursive

WHEELHOUSE=$PWD/wheelhouse

MULTIBUILD_DIR=$(dirname "${BASH_SOURCE[0]}")

if [ ! -d "$WHEELHOUSE" ]; then mkdir $WHEELHOUSE; fi
if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    source $MULTIBUILD_DIR/travis_osx_steps.sh
    whl_tail="*.whl"
else
    source $MULTIBUILD_DIR/travis_linux_steps.sh
    # Selects narrow build on Python 2.7
    whl_tail="*m-manylinux1_x86_64.whl"
fi

function install_wheel {
    if [ -n "$TEST_DEPENDS" ]; then pip install $TEST_DEPENDS; fi
    pip install $WHEELHOUSE/$whl_tail
}
