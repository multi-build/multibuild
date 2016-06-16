#!/bin/bash
# Depends on:
#   REPO_DIR | PKG_SPEC
#       (REPO_DIR for in source build; PKG_SPEC for pip build)
#   PYTHON_VERSION
#   BUILD_COMMIT
#   UNICODE_WIDTH  (can be empty)
#   BUILD_DEPENDS  (can be empty)
set -e

# Manylinux, openblas version, lex_ver, Python versions
MULTIBUILD_DIR=$(dirname "${BASH_SOURCE[0]}")
source $MULTIBUILD_DIR/manylinux_utils.sh
source $MULTIBUILD_DIR/common_utils.sh

# Configuration for this package
source /io/config_funcs.sh

# Unicode widths
UNICODE_WIDTH=${UNICODE_WIDTH:-32}
WHEEL_SDIR=${WHEEL_SDIR:-wheelhouse}

# Do any building prior to package building
if [ -n $(is_function "pre_build") ]; then
    # Library building tools
    source $MULTIBUILD_DIR/docker_lib_builders.sh
    pre_build
fi

# Directory to store wheels
rm_mkdir /unfixed_wheels

if [ -n "$REPO_DIR" ]; then
    # Enter source tree
    cd /io/$REPO_DIR
    build_source="."
elif [ -n "$PKG_SPEC" ]; then
    build_source=$PKG_SPEC
else:
    echo "Must specify REPO_DIR or PKG_SPEC"
    exit 1
fi

WHEELHOUSE=/io/$WHEEL_SDIR

# Compile wheel
PIP="$(cpython_path $PYTHON_VERSION $UNICODE_WIDTH)/bin/pip"
if [ -n "$BUILD_DEPENDS" ]; then
    $PIP install -f $MANYLINUX_URL $BUILD_DEPENDS
fi
clean_fix_source $BUILD_COMMIT
if [ -n "$REPO_DIR" ]; then clean_fix_source $BUILD_COMMIT; fi
$PIP wheel -f $MANYLINUX_URL -w /unfixed_wheels --no-deps $build_source

# Bundle external shared libraries into the wheels
repair_wheelhouse /unfixed_wheels $WHEELHOUSE
