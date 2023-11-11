#!/bin/bash
# Despite the name, this file is not specific to Travis-CI.
# It sets up the local environment for wheel building and testing.
# For Mac, configure xcode, and set up before_install and other
# functions to wrap builds.
# For linux, set up before_install to work in virtualenv, and set up wrapping
# to run build and tests in docker containers.

WHEEL_SDIR=${WHEEL_SDIR:-wheelhouse}

MULTIBUILD_DIR=$(dirname "${BASH_SOURCE[0]}")

if [ ! -d "$PWD/$WHEEL_SDIR" ]; then mkdir $PWD/$WHEEL_SDIR; fi
if [[ "$(uname)" == "Darwin" ]]; then
    source $MULTIBUILD_DIR/travis_osx_steps.sh
else
    source $MULTIBUILD_DIR/travis_linux_steps.sh
fi
