#!/bin/bash
# Depends on:
#   BUILD_COMMANDS
#   PYTHON_VERSION
#   CONFIG_PATH (can be empty)
#   BUILD_COMMIT (may be used by config.sh)
#   UNICODE_WIDTH  (can be empty)
#   BUILD_DEPENDS  (may be used by config.sh, can be empty)
set -e

# Change into root directory of repo
cd /io

# Location of wheels, default "wheelhouse"
WHEEL_SDIR=${WHEEL_SDIR:-wheelhouse}

# Location of `config.sh` file, default "./config.sh"
CONFIG_PATH=${CONFIG_PATH:-config.sh}

# Path is relative to repository from which we ran
ENV_VARS_PATH=${ENV_VARS_PATH:-env_vars.sh}

# Always pull in common and library builder utils
MULTIBUILD_DIR=$(dirname "${BASH_SOURCE[0]}")
# These routines also source common_utils.sh
source $MULTIBUILD_DIR/manylinux_utils.sh
if [ -r "$ENV_VARS_PATH" ]; then source "$ENV_VARS_PATH"; fi
source $MULTIBUILD_DIR/configure_build.sh
source $MULTIBUILD_DIR/library_builders.sh

if [ "$USE_CCACHE" == "1" ]; then
    activate_ccache
fi

# The following also sets PYTHON_EXE and PIP_CMD
if [ "${PYTHON_VERSION:0:4}" == "pypy" ]; then
  install_pypy $PYTHON_VERSION
  export PATH=$(dirname $PYTHON_EXE):$PATH
else
  # Set PATH for chosen Python, Unicode width
  PYTHON_EXE=$(cpython_path $PYTHON_VERSION $UNICODE_WIDTH)/bin/python
  ls $(dirname $PYTHON_EXE)
  export PATH="$(dirname $PYTHON_EXE):$PATH"
  # We can assume ensurepip is available and up to date.
  $PYTHON_EXE -m ensurepip
  PIP_CMD="$PYTHON_EXE -m pip"
fi

# Configuration for this package, possibly overriding `build_wheel` defined in
# `common_utils.sh` via `manylinux_utils.sh`.
source "$CONFIG_PATH"

$BUILD_COMMANDS
