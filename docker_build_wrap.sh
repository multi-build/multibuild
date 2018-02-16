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

# Unicode width, default 32
UNICODE_WIDTH=${UNICODE_WIDTH:-32}

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

# Set PATH for chosen Python, Unicode width
export PATH="$(cpython_path $PYTHON_VERSION $UNICODE_WIDTH)/bin:$PATH"

# Configuration for this package, possibly overriding `build_wheel` defined in
# `common_utils.sh` via `manylinux_utils.sh`.
source "$CONFIG_PATH"

$BUILD_COMMANDS
