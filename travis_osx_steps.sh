#!/bin/bash
# Install and wheel building steps on OSX
set -e

# Get needed utilities
ROOT_DIR=$(dirname "${BASH_SOURCE[0]}")
TERRYFY_DIR=$ROOT_DIR/terryfy
source $TERRYFY_DIR/travis_tools.sh

function before_install {
    export CC=clang
    export CXX=clang++
    get_python_environment macpython $TRAVIS_PYTHON_VERSION venv
    source venv/bin/activate
    pip install --upgrade pip wheel
}

function build_wheels {
    # Builds wheel, puts into $WHEELHOUSE
    #
    # Depends on
    #  REPO_DIR | PKG_SPEC
    #  BUILD_DEPENDS
    #  BUILD_COMMIT
    #  WHEELHOUSE
    if [-n "$BUILD_DEPENDS" ]; then pip install $BUILD_DEPENDS; fi
    if [ -n "$REPO_DIR" ]; then
        cd $REPO_DIR
        git fetch origin
        git checkout $BUILD_COMMIT
        git clean -fxd
        pip wheel -w $WHEELHOUSE --no-deps .
        cd ..
    else
        pip wheel -w $WHEELHOUSE --no-deps $PKG_SPEC
    fi
    pip install delocate
    delocate-listdeps $WHEELHOUSE/*.whl # lists library dependencies
    delocate-wheel $WHEELHOUSE/*.whl # copies library dependencies into wheel
    delocate-addplat --rm-orig -x 10_9 -x 10_10 $WHEELHOUSE/*.whl
}
