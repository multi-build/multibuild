# Test some library builders
# Smoke test
export BUILD_PREFIX="${PWD}/builds"
rm_mkdir $BUILD_PREFIX
source configure_build.sh
source library_builders.sh

start_spinner

suppress build_bzip2
suppress build_openssl
suppress build_libpng
suppress build_libwebp
suppress build_szip
suppress build_swig
# We need to find a failable test for build_github
# It needs a standalone C library with ./configure script.
# E.g. arb (below) requires a couple of other libraries.
# Run here just for the output, even though they fail.
(set +e ;
    build_github fredrik-johansson/arb 2.15.0 ;
    build_github glennrp/libpng v1.6.36 ;
    build_github wbhart/mpir mpir-3.0.0
    )
suppress build_flex
suppress build_openblas
suppress build_tiff
suppress build_lcms2
suppress build_xz
suppress build_freetype
suppress build_libyaml
if [ -z "$IS_OSX" ]; then
    # Gives compiler conformance error on macOS Sierra:
    # https://gist.github.com/5e20e137ea51fa8ca9fc443191f9d463
    # https://gist.github.com/ad86c474f3c0b7ec74290bb13f9414af
    suppress build_lzo
fi
suppress build_ragel
suppress build_cfitsio
suppress build_new_zlib

stop_spinner
