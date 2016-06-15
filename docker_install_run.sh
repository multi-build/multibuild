#!/bin/bash
# Install and test steps on Linux
set -e

# Get needed utilities
MULTIBUILD_DIR=$(dirname "${BASH_SOURCE[0]}")
source $MULTIBUILD_DIR/common_utils.sh

install_run $RUN_TESTS_SCRIPT
