# Test some library builders

# The environment
uname -a

if [ -n "$IS_MACOS" ]; then
    # Building on macOS
    export BUILD_PREFIX="${PWD}/builds"
    rm_mkdir $BUILD_PREFIX
    source configure_build.sh
    source library_builders.sh
else
    # Building on Linux
    # Glibc version
    ldd --version
    # configure_build.sh, library_builders.sh sourced in
    # docker_build_wrap.sh
fi

source tests/utils.sh

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
    build_github fredrik-johansson/arb 2.19.0 ;
    build_github glennrp/libpng v1.6.37 ;
    build_github wbhart/mpir mpir-3.0.0
    )
suppress build_flex
suppress build_openblas
suppress build_tiff
suppress build_lcms2
suppress ensure_xz
suppress build_freetype
suppress build_libyaml
if [ -z "$IS_MACOS" ]; then
    # Gives compiler conformance error on macOS Sierra:
    # https://gist.github.com/5e20e137ea51fa8ca9fc443191f9d463
    # https://gist.github.com/ad86c474f3c0b7ec74290bb13f9414af
    suppress build_lzo
fi
suppress build_ragel
if [ -z "$IS_MACOS" ]; then
    # already installed in the macOS image, so `brew install cfitsio` fails
    suppress build_cfitsio
fi
suppress build_new_zlib
suppress build_hdf5
suppress get_modern_cmake

[ ${MB_PYTHON_VERSION+x} ] || ingest "\$MB_PYTHON_VERSION is not set"
[ "$MB_PYTHON_VERSION" == "$PYTHON_VERSION" ] || ingest "\$MB_PYTHON_VERSION must be equal to \$PYTHON_VERSION"

stop_spinner

# Exit 1 if any test errors
barf
