#!/bin/bash
# Wheel build, install, run test steps on OSX
set -e

# Get needed utilities
MULTIBUILD_DIR=$(dirname "${BASH_SOURCE[0]}")
MB_PYTHON_VERSION=${MB_PYTHON_VERSION:-$TRAVIS_PYTHON_VERSION}

ENV_VARS_PATH=${ENV_VARS_PATH:-env_vars.sh}

if [ "$PLAT" == "universal2" ] || [ "$PLAT" == "arm64" ]; then
  if [ "$TRAVIS" == "true" ]; then
    # Setup xcode and compilers to use the new SDK for universal2 and arm64 builds
    sudo xcode-select -switch /Applications/Xcode_12.2.app
    export SDKROOT=/Applications/Xcode_12.2.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX11.0.sdk
  fi
fi

# These load common_utils.sh
source $MULTIBUILD_DIR/osx_utils.sh
MB_PYTHON_OSX_VER=${MB_PYTHON_OSX_VER:-$(macpython_sdk_for_version $MB_PYTHON_VERSION)}

if [ -r "$ENV_VARS_PATH" ]; then source "$ENV_VARS_PATH"; fi
source $MULTIBUILD_DIR/configure_build.sh
source $MULTIBUILD_DIR/library_builders.sh

# NB - config.sh sourced at end of this function.
# config.sh can override any function defined here.

function before_install {
    export CC=clang
    export CXX=clang++

    get_macpython_environment $MB_PYTHON_VERSION venv
    source venv/bin/activate
    pip install --upgrade pip wheel
}

# build_wheel function defined in common_utils (via osx_utils)
# install_run function defined in common_utils

# Local configuration may define custom pre-build, source patching.
# It can also overwrite the functions above.
CONFIG_PATH=${CONFIG_PATH:-config.sh}
source "$CONFIG_PATH"
