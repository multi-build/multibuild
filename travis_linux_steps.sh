#!/bin/bash
# Wheel build, install, run test steps on Linux
set -e

# Get our own location on this filesystem
MULTIBUILD_DIR=$(dirname "${BASH_SOURCE[0]}")

# Docker build script
BUILD_SCRIPT=${BUILD_SCRIPT:-${MULTIBUILD_DIR}/docker_build_package.sh}

UNICODE_WIDTH=${UNICODE_WIDTH:-32}

function before_install {
    virtualenv --python=python venv
    source venv/bin/activate
    python --version # just to check
    pip install --upgrade pip wheel
}

function build_wheel {
    # Builds wheel, puts into $WHEEL_SDIR
    #
    # Depends on
    #  PLAT
    #  BUILD_DEPENDS
    #  BUILD_COMMIT
    #  BUILD_PRE_SCRIPT
    #  BUILD_SCRIPT
    #  REPO_DIR | PKG_SPEC
    #  TRAVIS_PYTHON_VERSION
    local plat=${1:-$PLAT}
    local docker_image=quay.io/pypa/manylinux1_$plat
    docker pull $docker_image
    docker run --rm \
        -e PYTHON_VERSION="$TRAVIS_PYTHON_VERSION" \
        -e UNICODE_WIDTH="$UNICODE_WIDTH" \
        -e WHEEL_SDIR="$WHEEL_SDIR" \
        -e MANYLINUX_URL="$MANYLINUX_URL" \
        -e BUILD_DEPENDS="$BUILD_DEPENDS" \
        -e BUILD_COMMIT="$BUILD_COMMIT" \
        -e PKG_SPEC="$PKG_SPEC" \
        -e REPO_DIR="$REPO_DIR" \
        -v $PWD:/io \
        $docker_image /io/$BUILD_SCRIPT
}

function relpath {
    python -c "import os.path; print(os.path.relpath('$1','${2:-$PWD}'))"
}

function install_run {
    local plat=${1:-$PLAT}
    bitness=$([ "$plat" == i686 ] && echo 32 || echo 64)
    local docker_image="matthewbrett/trusty:$bitness"
    local multibuild_sdir=$(relpath $MULTIBUILD_DIR)
    docker pull $docker_image
    docker run --rm \
        -e PYTHON_VERSION="$TRAVIS_PYTHON_VERSION" \
        -e UNICODE_WIDTH="$UNICODE_WIDTH" \
        -e WHEEL_SDIR="$WHEEL_SDIR" \
        -e MANYLINUX_URL="$MANYLINUX_URL" \
        -e TEST_DEPENDS="$TEST_DEPENDS" \
        -v $PWD:/io \
        $docker_image /io/$multibuild_sdir/docker_install_run.sh
}
