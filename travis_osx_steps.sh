#!/bin/bash
# Wheel build, install, run test steps on OSX
set -e

# Get needed utilities
MULTIBUILD_DIR=$(dirname "${BASH_SOURCE[0]}")
source $MULTIBUILD_DIR/terryfy/travis_tools.sh

# Local configuration may define custom pre-build, source patching
source $PWD/config_funcs.sh

function before_install {
    export CC=clang
    export CXX=clang++
    get_python_environment macpython $TRAVIS_PYTHON_VERSION venv
    source venv/bin/activate
    pip install --upgrade pip wheel
}

function build_wheel {
    # Builds wheel, puts into $WHEEL_SDIR
    #
    # Depends on
    #  WHEEL_SDIR
    #  BUILD_DEPENDS
    #  REPO_DIR | PKG_SPEC
    #  BUILD_COMMIT
    local wheelhouse=$PWD/$WHEEL_SDIR
    if [ -n $(is_function "pre_build") ]; then pre_build; fi
    if [ -n "$BUILD_DEPENDS" ]; then pip install $BUILD_DEPENDS; fi
    if [ -n "$REPO_DIR" ]; then
        (cd $REPO_DIR \
            && clean_fix_source $BUILD_COMMIT \
            && pip wheel -w $wheelhouse --no-deps .)
    else
        pip wheel -w $wheelhouse --no-deps $PKG_SPEC
    fi
    pip install delocate
    delocate-listdeps $wheelhouse/*.whl # lists library dependencies
    delocate-wheel $wheelhouse/*.whl # copies library dependencies into wheel
    delocate-addplat --rm-orig -x 10_9 -x 10_10 $wheelhouse/*.whl
}
