# Test some library builders
# Smoke test
export BUILD_PREFIX="${PWD}/builds"
rm_mkdir $BUILD_PREFIX
source library_builders.sh

build_openssl
suppress build_github fredrik-johansson/arb 2.11.1
