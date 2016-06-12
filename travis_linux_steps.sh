#!/bin/bash
# Travis steps for Linux
set -e

ROOT_DIR=$(dirname "${BASH_SOURCE[0]}")
UTIL_DIR=${UTIL_DIR:-${ROOT_DIR}/manylinux}
BUILD_SCRIPT=${BUILD_SCRIPT:-/io/$UTIL_DIR/build_package.sh}
UNICODE_WIDTHS=${UNICODE_WIDTHS:-32}

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
    #  REPO_DIR | PKG_SPEC
    #  TRAVIS_PYTHON_VERSION
    #
    # Build both 32- and 64-bit
    build_plat_wheels i686
    build_plat_wheels x86_64
}

function valid_unicode_widths {
    local py_ver=${1:-$TRAVIS_PYTHON_VERSION}
    local ok_widths=""
    if [ "${py_ver:0:1}" == 2 ]; then local py2=1; fi
    for width in ${@:2}; do
        if [ "$width" == 32 ]; then
            ok_widths="$ok_widths 32"
        elif [ "$width" == 16 ]; then
            if [ -n "$py2" ]; then
                ok_widths="$ok_widths 16"
            fi
        else
            echo "Invalid unicode width $width"
            exit 1
        fi
    done
    echo $ok_widths
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
    #  REPO_DIR | PKG_SPEC
    #  TRAVIS_PYTHON_VERSION
    local plat=${1:-x86_64}
    local docker_image=quay.io/pypa/manylinux1_$plat
    docker pull $docker_image
    if [ "$plat" == "i686" ]; then local intro_cmd=linux32; fi
    local widths=$(valid_unicode_widths $TRAVIS_PYTHON_VERSION $UNICODE_WIDTHS)
    docker run --rm \
        -e UTIL_DIR="$UTIL_DIR" \
        -e PYTHON_VERSION="$TRAVIS_PYTHON_VERSION" \
        -e UNICODE_WIDTHS="$widths" \
        -e BUILD_DEPENDS="$BUILD_DEPENDS" \
        -e BUILD_COMMIT="$BUILD_COMMIT" \
        -e BUILD_PRE_SCRIPT="$BUILD_PRE_SCRIPT" \
        -e PKG_SPEC="$PKG_SPEC" \
        -e REPO_DIR="$REPO_DIR" \
        -v $PWD:/io \
        $docker_image $intro_cmd $BUILD_SCRIPT
}
