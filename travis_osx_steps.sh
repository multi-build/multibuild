#!/bin/bash
# Wheel build, install, run test steps on OSX
set -e

function check_sdk_11 {
  ver="$(xcrun -show-sdk-version)"
  if [[ "${ver}" == "" || "${ver}" == 10.* ]]; then
    echo "not found"
  else
    echo "found"
  fi
}

if [ "$PLAT" == "arm64" ] || [ "$PLAT" == "universal2" ]; then
  if [[ "$(check_sdk_11)" == "not found"  ]]; then
    latestXcode=$(ls /Applications | grep Xcode[_0-9\.]*\.app | sort -V | tail -n 1)
    if ([ "$GITHUB_WORKFLOW" != "" ] || [ "$PIPELINE_WORKSPACE" != "" ]) && [ $latestXcode ]; then
      sudo xcode-select -switch /Applications/$latestXcode.app
    fi
    if [[ "$(check_sdk_11)" == "not found" ]]; then
      echo "Need SDK>=11 for arm64 builds. Please run xcode-select to select a newer SDK"
      exit 1
    fi
  fi
  export SDKROOT=${SDKROOT:-$(xcrun -show-sdk-path)}
fi

# Get needed utilities
MULTIBUILD_DIR=$(dirname "${BASH_SOURCE[0]}")
MB_PYTHON_VERSION=${MB_PYTHON_VERSION:-$TRAVIS_PYTHON_VERSION}

ENV_VARS_PATH=${ENV_VARS_PATH:-env_vars.sh}

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
