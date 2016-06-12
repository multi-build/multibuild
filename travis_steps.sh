#!/bin/bash
WHEELHOUSE=$PWD/wheelhouse
if [ !-d $WHEELHOUSE ]; then mkdir wheelhouse; fi
if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    source travis_osx_steps.sh
    whl_tail="*.whl"
else
    source travis_linux_steps.sh
    whl_tail="*manylinux1_x86_64.whl"
fi

function install_wheel {
    if [ -n "$TEST_DEPENDS" ]; then pip install $TEST_DEPENDS; fi
    pip install $WHEELHOUSE/$whl_tail
}
