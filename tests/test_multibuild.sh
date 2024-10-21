# Test multibuild utilities
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
set -x
source common_utils.sh
# This is normally set
# - on linux via docker_build_wrap.sh, docker_test_wrap.sh
# - on macOS via make_workon_env or install_macpython,
#   which is called by get_macpython_environment which is called by before_install
# We call it here so that these pre-install tests succeed
PYTHON_EXE=python

source tests/utils.sh
source tests/test_common_utils.sh
source tests/test_fill_submodule.sh

# make sure it is set via one of the mechanisms above
unset PYTHON_EXE

if [ -n "$IS_MACOS" ]; then
    source osx_utils.sh
    MB_PYTHON_OSX_VER=${MB_PYTHON_OSX_VER:-$(macpython_sdk_for_version $MB_PYTHON_VERSION)}
    PLAT=${PLAT:-$(macpython_arch_for_version $MB_PYTHON_VERSION)}

    # exit early if this cmd is expected to fail (and does)
    if [[ -n $OSX_ENV_EXPECT_FAIL ]]; then
      expect_return 22 get_macpython_environment $MB_PYTHON_VERSION ${VENV:-""} $MB_PYTHON_OSX_VER
      exit 0
    fi
    get_macpython_environment $MB_PYTHON_VERSION ${VENV:-""} $MB_PYTHON_OSX_VER

    source tests/test_python_install.sh
    source tests/test_fill_pyver.sh
    source tests/test_fill_pypy_ver.sh
    source tests/test_osx_utils.sh
else
    source manylinux_utils.sh
    source tests/test_manylinux_utils.sh
fi
if [ -n "$TEST_BUILDS" ]; then
    MB_PYTHON_VERSION=${MB_PYTHON_VERSION:-3.7}
    if [ -n "$IS_MACOS" ]; then
        # This checked in test_library_builders.
        # Will be set automatically by docker call in build_multilinux below.
        PYTHON_VERSION=${MB_PYTHON_VERSION}
        source tests/test_library_builders.sh
        source tests/config.sh
    elif [ ! -x "$(command -v docker)" ]; then
        echo "Skipping build tests; no docker available"
    else
        touch config.sh
        source travis_linux_steps.sh
        my_plat=${PLAT:-x86_64}
        build_multilinux $my_plat "source tests/test_manylinux_utils_docker.sh"
        build_multilinux $my_plat "source tests/test_library_builders.sh"
        build_multilinux $my_plat "pip install simplejson"
        CONFIG_PATH=tests/config.sh
    fi
    build_index_wheel simplejson
    install_run $PLAT
fi

source tests/test_supported_wheels.sh

# Exit 1 if any test errors
barf
