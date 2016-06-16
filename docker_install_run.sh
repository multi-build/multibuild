#!/bin/bash
# Install and test steps on Linux
set -e

# Get needed utilities
MULTIBUILD_DIR=$(dirname "${BASH_SOURCE[0]}")
source $MULTIBUILD_DIR/common_utils.sh

# Configuration for this package
# This can ovverride `install_wheel`, otherwise defined in common_utils.sh.
# It must define `run_tests`.
source $(get_root)/config_funcs.sh

install_wheel
run_tests
