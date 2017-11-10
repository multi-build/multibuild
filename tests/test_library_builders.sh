# Test some library builders
# Smoke test
export BUILD_PREFIX="${PWD}/builds"
rm_mkdir $BUILD_PREFIX
source library_builders.sh

# set -e -x

if [ "$TRAVIS_OS_NAME" == "osx" ]; then brew update; fi

start_spinner

suppress build_openssl
suppress build_openblas
suppress build_libwebp
suppress build_szip
suppress build_swig
suppress build_github fredrik-johansson/arb 2.11.1

stop_spinner
