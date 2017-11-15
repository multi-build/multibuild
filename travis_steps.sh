#!/bin/bash

WHEEL_SDIR=${WHEEL_SDIR:-wheelhouse}

MULTIBUILD_DIR=$(dirname "${BASH_SOURCE[0]}")

if [ ! -d "$PWD/$WHEEL_SDIR" ]; then mkdir $PWD/$WHEEL_SDIR; fi
if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    source $MULTIBUILD_DIR/travis_osx_steps.sh
else
    source $MULTIBUILD_DIR/travis_linux_steps.sh
fi

# Promote BUILD_PREFIX on search path to any newly built libs
export CPPFLAGS="-L$BUILD_PREFIX/include $CPPFLAGS"
export LIBRARY_PATH="$BUILD_PREFIX/lib:$LIBRARY_PATH"
