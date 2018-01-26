# Test some library builders
# Smoke test
export BUILD_PREFIX="${PWD}/builds"
rm_mkdir $BUILD_PREFIX
source build_env+library_builders.sh

start_spinner

suppress build_openssl
suppress build_libpng
suppress build_libwebp
suppress build_szip
suppress build_swig
suppress build_github fredrik-johansson/arb 2.11.1
suppress build_flex
suppress build_openblas

stop_spinner
