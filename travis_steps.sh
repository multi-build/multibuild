#!/bin/bash
# Update submodules
git submodule update --init --recursive

WHEEL_SDIR=${WHEEL_SDIR:-wheelhouse}
MANYLINUX_URL=${MANYLINUX_URL:-https://nipy.bic.berkeley.edu/manylinux}
MULTIBUILD_DIR=$(dirname "${BASH_SOURCE[0]}")
# Get utilities common to OSX and Linux
source $MULTIBUILD_DIR/common_utils.sh

# Specify REPO_DIR to build from directory in this repository.
# Specify PKG_SPEC to build from pip requirement (e.g numpy==1.7.1)
# PKG_SPEC is hardly tested, please let us know of bugs.
if [ -z "$REPO_DIR$PKG_SPEC" ]; then
    echo "Must specify REPO_DIR or PKG_SPEC"
    exit 1
fi

if [ ! -d "$PWD/$WHEEL_SDIR" ]; then mkdir $PWD/WHEEL_SDIR; fi
if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    source $MULTIBUILD_DIR/travis_osx_steps.sh
else
    source $MULTIBUILD_DIR/travis_linux_steps.sh
fi
