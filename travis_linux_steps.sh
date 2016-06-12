#!/bin/bash
# Travis steps for Linux
set -ex

BUILD_SCRIPT=${BUILD_SCRIPT:-/io/manylinux/build_package.sh}

function before_install {
    virtualenv --python=python venv
    source venv/bin/activate
    python --version # just to check
    pip install --upgrade pip wheel
}

function build_wheels {
    # Builds wheel, puts into $WHEELHOUSE
    #
    # Depends on
    #  BUILD_DEPENDS
    #  BUILD_COMMIT
    #  BUILD_PRE_SCRIPT
    #  BUILD_SCRIPT
    #  REPO_DIR
    #  TRAVIS_PYTHON_VERSION
    #
    # Build both 32- and 64-bit
    build_plat_wheels i686
    build_plat_wheels x86_64
}

function build_plat_wheels {
    # Builds wheels
    #
    # Depends on
    #
    #  BUILD_DEPENDS  (can be empty)
    #  BUILD_COMMIT
    #  BUILD_PRE_SCRIPT  (can be empty)
    #  BUILD_SCRIPT
    #  REPO_DIR
    #  TRAVIS_PYTHON_VERSION
    local plat=${1:-x86_64}
    local docker_image=quay.io/pypa/manylinux1_$plat
    docker pull $docker_image
    if [ "$plat" == "i686" ]; then local intro_cmd=linux32; fi
    docker run --rm \
        -e PYTHON_VERSION=$TRAVIS_PYTHON_VERSION \
        -e UNICODE_WIDTHS=$UNICODE_WIDTHS \
        -e BUILD_DEPENDS=$BUILD_DEPENDS \
        -e BUILD_COMMIT=$BUILD_COMMIT \
        -e BUILD_PRE_SCRIPT=$BUILD_PRE_SCRIPT \
        -e REPO_DIR=$REPO_DIR \
        -v $PWD:/io \
        $docker_image $intro_cmd $BUILD_SCRIPT
}
