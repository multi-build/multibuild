#!/bin/bash
# Utilities for both OSX and Docker
# Python should be on the PATH
set -e

MULTIBUILD_DIR=$(dirname "${BASH_SOURCE[0]}")
if [ $(uname) == "Darwin" ]; then IS_OSX=1; fi

function abspath {
    python -c "import os.path; print(os.path.abspath('$1'))"
}

function relpath {
    # Path of first input relative to second (or $PWD if not specified)
    python -c "import os.path; print(os.path.relpath('$1','${2:-$PWD}'))"
}

function realpath {
    python -c "import os; print(os.path.realpath('$1'))"
}

function lex_ver {
    # Echoes dot-separated version string padded with zeros
    # Thus:
    # 3.2.1 -> 003002001
    # 3     -> 003000000
    echo $1 | awk -F "." '{printf "%03d%03d%03d", $1, $2, $3}'
}

function is_function {
    set +e
    $(declare -Ff "$1") > /dev/null && echo true
    set -e
}

function gh-clone {
    git clone https://github.com/$1
}

function rm_mkdir {
    # Remove directory if present, then make directory
    local path=$1
    [ -z "$path" ] && echo "Need not-empty path" && exit 1
    [ -d "$path" ] && rm -rf $path
    mkdir $path
}

function clean_code {
    local repo_dir=${1:-$REPO_DIR}
    local build_commit=${2:-$BUILD_COMMIT}
    [ -z "$repo_dir" ] && echo "repo_dir not defined" && exit 1
    [ -z "$build_commit" ] && echo "build_commit not defined" && exit 1
    (cd $repo_dir \
        && git fetch origin \
        && git checkout $build_commit \
        && git clean -fxd \
        && git reset --hard \
        && git submodule update --init --recursive)
}

function build_wheel {
    # Builds wheel, puts into $WHEEL_SDIR
    #
    # Depends on
    #     REPO_DIR  (or via input argument)
    #     WHEEL_SDIR  (optional, default "wheelhouse")
    #     BUILD_DEPENDS (optional, default "")
    #     MANYLINUX_URL (optional, default "") (via pip_opts function)
    local repo_dir=${1:-$REPO_DIR}
    [ -z "$repo_dir" ] && echo "repo_dir not defined" && exit 1
    local wheelhouse=$(abspath ${WHEEL_SDIR:-wheelhouse})
    if [ -n $(is_function "pre_build") ]; then pre_build; fi
    if [ -n "$BUILD_DEPENDS" ]; then pip install $(pip_opts) $BUILD_DEPENDS; fi
    (cd $repo_dir && pip wheel $(pip_opts) -w $wheelhouse --no-deps .)
    repair_wheelhouse $wheelhouse
}

function pip_opts {
    [ -n "$MANYLINUX_URL" ] && echo "--find-links $MANYLINUX_URL"
}

function install_wheel {
    # Install test dependencies and built wheel
    #
    # Pass any input flags to pip install steps
    #
    # Depends on:
    #     WHEEL_SDIR  (optional, default "wheelhouse")
    #     TEST_DEPENDS  (optional, default "")
    #     MANYLINUX_URL (optional, default "") (via pip_opts function)
    local wheelhouse=$(abspath ${WHEEL_SDIR:-wheelhouse})
    if [ -n "$TEST_DEPENDS" ]; then
        pip install $(pip_opts) $@ $TEST_DEPENDS
    fi
    # Install compatible wheel
    pip install $(pip_opts) $@ \
        $(python $MULTIBUILD_DIR/supported_wheels.py $wheelhouse/*.whl)
}

function install_run {
    # Depends on function `run_tests` defined in `config.sh`
    install_wheel
    mkdir tmp_for_test
    (cd tmp_for_test && run_tests)
}
