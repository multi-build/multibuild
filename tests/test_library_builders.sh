# Test some library builders
# Smoke test
export BUILD_PREFIX="${PWD}/builds"
rm_mkdir $BUILD_PREFIX
source configure_build.sh
source library_builders.sh

start_spinner

suppress build_openssl
suppress build_libpng
suppress build_libwebp
suppress build_szip
suppress build_swig
# We need to find a test for build_github
# It needs a standalone C library with ./configure script.
# arb (below) requires a couple of other libraries.
# suppress build_github fredrik-johansson/arb 2.13.0
suppress build_flex
suppress build_openblas
suppress build_tiff
suppress build_lcms2
suppress build_xz
suppress build_freetype
suppress build_libyaml
suppress build_lzo
suppress build_ragel
suppress build_new_zlib

stop_spinner
