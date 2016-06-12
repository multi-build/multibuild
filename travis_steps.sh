#!/bin/bash
WHEELHOUSE=$PWD/wheelhouse
if [ !-d $WHEELHOUSE ]; then mkdir wheelhouse; fi
PKG_NAME=${PKG_NAME:-$REPO_DIR}
if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    source travis_osx_steps.sh
else
    source travis_linux_steps.sh
fi

function install_wheel {
    if [ -n "$TEST_DEPENDS" ]; then pip install $TEST_DEPENDS; fi
    pip install -f $WHEELHOUSE --no-index $PKG_NAME
}
