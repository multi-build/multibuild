#!/bin/bash
# Depends on:
#   BUILD_COMMANDS
#   PYTHON_VERSION
#   BUILD_COMMIT (may be used by config.sh)
#   UNICODE_WIDTH  (can be empty)
#   BUILD_DEPENDS  (may be used by config.sh, can be empty)
set -e

function activate_ccache {
    # Link up the correct location for ccache
    ln -s /parent-home/.ccache $HOME/.ccache

    # Now install ccache
    yum install -y ccache

    # Create fake compilers and prepend them to the PATH
    # Note that yum is supposed to create these for us,
    # but I had trouble finding them
    local ccache_dir=/usr/lib/ccache/compilers
    mkdir -p $ccache_dir
    ln -s /usr/bin/ccache $CCACHE_DIR/gcc
    ln -s /usr/bin/ccache $CCACHE_DIR/g++
    ln -s /usr/bin/ccache $CCACHE_DIR/cc
    ln -s /usr/bin/ccache $CCACHE_DIR/c++
    export PATH=$CCACHE_DIR:$PATH

    # Prove to the developer that ccache is activated
    which gcc
}

if [ $USE_CCACHE == 1 ]; then
    activate_ccache
fi

# Unicode width, default 32
UNICODE_WIDTH=${UNICODE_WIDTH:-32}

# Location of wheels, default "wheelhouse"
WHEEL_SDIR=${WHEEL_SDIR:-wheelhouse}

# Always pull in common and library builder utils
MULTIBUILD_DIR=$(dirname "${BASH_SOURCE[0]}")
# These routines also source common_utils.sh
source $MULTIBUILD_DIR/manylinux_utils.sh
source $MULTIBUILD_DIR/library_builders.sh

# Set PATH for chosen Python, Unicode width
export PATH="$(cpython_path $PYTHON_VERSION $UNICODE_WIDTH)/bin:$PATH"

# Change into root directory of repo
cd /io

# Configuration for this package, possibly overriding `build_wheel` defined in
# `common_utils.sh` via `manylinux_utils.sh`.
source config.sh

$BUILD_COMMANDS
