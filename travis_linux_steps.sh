#!/bin/bash
# Wheel build, install, run test steps on Linux
#
# In fact the main work is to wrap up the real functions in docker commands.
# The real work is in the BUILD_SCRIPT (which builds the wheel) and
# `docker_install_run.sh`, which can be configured with `config.sh`.
#
# Must define
#  before_install
#  build_wheel
#  install_run
set -e

# Get our own location on this filesystem
MULTIBUILD_DIR=$(dirname "${BASH_SOURCE[0]}")

# Allow travis Python version as proxy for multibuild Python version
MB_PYTHON_VERSION=${MB_PYTHON_VERSION:-$TRAVIS_PYTHON_VERSION}

function before_install {
    # Install a virtualenv to work in.
    virtualenv --python=$PYTHON_EXE venv
    source venv/bin/activate
    python --version # just to check
    pip install --upgrade pip wheel
}

function build_wheel {
    # Builds wheel, puts into $WHEEL_SDIR
    #
    # In fact wraps the actual work which happens in the container.
    #
    # Depends on
    #     REPO_DIR  (or via input argument)
    #     PLAT (can be passed in as argument)
    #     MB_PYTHON_VERSION
    #     BUILD_COMMIT
    #     UNICODE_WIDTH (optional)
    #     BUILD_DEPENDS (optional)
    #     MANYLINUX_URL (optional)
    #     WHEEL_SDIR (optional)
    local repo_dir=${1:-$REPO_DIR}
    [ -z "$repo_dir" ] && echo "repo_dir not defined" && exit 1
    local plat=${2:-${PLAT:-x86_64}}
    build_multilinux $plat "build_wheel $repo_dir"
}

function build_index_wheel {
    # Builds wheel from an index (e.g pypi), puts into $WHEEL_SDIR
    #
    # In fact wraps the actual work which happens in the container.
    #
    # Depends on
    #     PLAT (can be passed in as argument)
    #     MB_PYTHON_VERSION
    #     UNICODE_WIDTH (optional)
    #     BUILD_DEPENDS (optional)
    #     MANYLINUX_URL (optional)
    #     WHEEL_SDIR (optional)
    local project_spec=$1
    [ -z "$project_spec" ] && echo "project_spec not defined" && exit 1
    local plat=${2:-${PLAT:-x86_64}}
    build_multilinux $plat "build_index_wheel $project_spec"
}

function build_multilinux {
    # Runs passed build commands in manylinux container
    #
    # Depends on
    #     MB_PYTHON_VERSION
    #     MB_ML_VER
    #     UNICODE_WIDTH (optional)
    #     BUILD_DEPENDS (optional)
    #     DOCKER_IMAGE (optional)
    #     MANYLINUX_URL (optional)
    #     WHEEL_SDIR (optional)
    local plat=$1
    [ -z "$plat" ] && echo "plat not defined" && exit 1
    local build_cmds="$2"
    local docker_image=${DOCKER_IMAGE:-quay.io/pypa/manylinux${MB_ML_VER}_\$plat}
    docker_image=$(eval echo "$docker_image")
    retry docker pull $docker_image
    docker run --rm \
        -e BUILD_COMMANDS="$build_cmds" \
        -e PYTHON_VERSION="$MB_PYTHON_VERSION" \
        -e MB_PYTHON_VERSION="$MB_PYTHON_VERSION" \
        -e UNICODE_WIDTH="$UNICODE_WIDTH" \
        -e BUILD_COMMIT="$BUILD_COMMIT" \
        -e CONFIG_PATH="$CONFIG_PATH" \
        -e ENV_VARS_PATH="$ENV_VARS_PATH" \
        -e WHEEL_SDIR="$WHEEL_SDIR" \
        -e MANYLINUX_URL="$MANYLINUX_URL" \
        -e BUILD_DEPENDS="$BUILD_DEPENDS" \
        -e USE_CCACHE="$USE_CCACHE" \
        -e REPO_DIR="$repo_dir" \
        -e PLAT="$PLAT" \
        -e MB_ML_VER="$MB_ML_VER" \
        -v $PWD:/io \
        -v $HOME:/parent-home \
        $docker_image /io/$MULTIBUILD_DIR/docker_build_wrap.sh
}

function install_run {
    # Install wheel, run tests
    #
    # In fact wraps the actual work which happens in the container.
    #
    # Depends on
    #  PLAT (can be passed in as argument)
    #  MB_PYTHON_VERSION
    #  UNICODE_WIDTH (optional)
    #  WHEEL_SDIR (optional)
    #  MANYLINUX_URL (optional)
    #  TEST_DEPENDS  (optional)
    #  MB_TEST_VER (optional)
    local plat=${1:-${PLAT:-x86_64}}
    if [ -z "$DOCKER_TEST_IMAGE" ]; then
        local bitness=$([ "$plat" == i686 ] && echo 32 || echo 64)
        local docker_image="matthewbrett/trusty:$bitness"
    else
        # aarch64 is called arm64v8 in Ubuntu
        local plat_subst=$([ "$plat" == aarch64 ] && echo arm64v8 || echo $plat)
        local docker_image="${DOCKER_TEST_IMAGE/\{PLAT\}/$plat_subst}"
    fi
    docker pull $docker_image
    docker run --rm \
        -e PYTHON_VERSION="$MB_PYTHON_VERSION" \
        -e MB_PYTHON_VERSION="$MB_PYTHON_VERSION" \
        -e UNICODE_WIDTH="$UNICODE_WIDTH" \
        -e CONFIG_PATH="$CONFIG_PATH" \
        -e WHEEL_SDIR="$WHEEL_SDIR" \
        -e MANYLINUX_URL="$MANYLINUX_URL" \
        -e TEST_DEPENDS="$TEST_DEPENDS" \
        -e PLAT="$PLAT" \
        -v $PWD:/io \
        $docker_image /io/$MULTIBUILD_DIR/docker_test_wrap.sh
}
