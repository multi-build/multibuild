#Functions and environment variables to build various
#native libraries commonly used as dependencies

MULTIBUILD_DIR=$(dirname "${BASH_SOURCE[0]}")
source $MULTIBUILD_DIR/_gfortran_utils.sh
source $MULTIBUILD_DIR/configure_build.sh

# For OpenBLAS
GF_LIB_URL="https://3f23b170c54c2533c070-1c8a9b3114517dc5fe17b7c3f8c63a43.ssl.cf2.rackcdn.com"

# Recipes for building some libraries
OPENBLAS_VERSION="${OPENBLAS_VERSION:-0.2.18}"
# We use system zlib by default - see build_new_zlib
ZLIB_VERSION="${ZLIB_VERSION:-1.2.10}"
LIBPNG_VERSION="${LIBPNG_VERSION:-1.6.21}"
BZIP2_VERSION="${BZIP2_VERSION:-1.0.6}"
FREETYPE_VERSION="${FREETYPE_VERSION:-2.6.3}"
TIFF_VERSION="${TIFF_VERSION:-4.0.6}"
JPEG_VERSION="${JPEG_VERSION:-9b}"
OPENJPEG_VERSION="${OPENJPEG_VERSION:-2.1}"
LCMS2_VERSION="${LCMS2_VERSION:-2.7}"
GIFLIB_VERSION="${GIFLIB_VERSION:-5.1.3}"
LIBWEBP_VERSION="${LIBWEBP_VERSION:-0.5.0}"
XZ_VERSION="${XZ_VERSION:-5.2.2}"
LIBYAML_VERSION="${LIBYAML_VERSION:-0.1.5}"
SZIP_VERSION="${SZIP_VERSION:-2.1.1}"
HDF5_VERSION="${HDF5_VERSION:-1.10.4}"
LIBAEC_VERSION="${LIBAEC_VERSION:-0.3.3}"
LZO_VERSION=${LZO_VERSION:-2.10}
LZF_VERSION="${LZF_VERSION:-3.6}"
BLOSC_VERSION=${BLOSC_VERSION:-1.10.2}
SNAPPY_VERSION="${SNAPPY_VERSION:-1.1.3}"
CURL_VERSION=${CURL_VERSION:-7.49.1}
NETCDF_VERSION=${NETCDF_VERSION:-4.4.1.1}
SWIG_VERSION=${SWIG_VERSION:-3.0.12}
PCRE_VERSION=${PCRE_VERSION:-8.38}
SUITESPARSE_VERSION=${SUITESPARSE_VERSION:-4.5.6}
LIBTOOL_VERSION=${LIBTOOL_VERSION:-2.4.6}
RAGEL_VERSION=${RAGEL_VERSION:-6.10}
FLEX_VERSION=${FLEX_VERSION:-2.6.4}
BISON_VERSION=${BISON_VERSION:-3.0.4}
FFTW_VERSION=${FFTW_VERSION:-3.3.7}
CFITSIO_VERSION=${CFITSIO_VERSION:-3370}
OPENSSL_ROOT=openssl-1.0.2l
# Hash from https://www.openssl.org/source/openssl-1.0.2?.tar.gz.sha256
OPENSSL_HASH=ce07195b659e75f4e1db43552860070061f156a98bb37b672b101ba6e3ddf30c
OPENSSL_DOWNLOAD_URL=https://www.openssl.org/source


ARCHIVE_SDIR=${ARCHIVE_DIR:-archives}


function build_simple {
    # Example: build_simple libpng $LIBPNG_VERSION \
    #               https://download.sourceforge.net/libpng tar.gz \
    #               --additional --configure --arguments
    local name=$1
    local version=$2
    local url=$3
    local ext=${4:-tar.gz}
    local configure_args=${@:5}
    if [ -e "${name}-stamp" ]; then
        return
    fi
    local name_version="${name}-${version}"
    local archive=${name_version}.${ext}
    fetch_unpack $url/$archive
    (cd $name_version \
        && ./configure --prefix=$BUILD_PREFIX $configure_args \
        && make -j4 \
        && make install)
    touch "${name}-stamp"
}

function build_github {
    # Example: build_github fredrik-johansson/arb 2.11.1
    local path=$1
    local tag_name=$2
    local configure_args=${@:3}
    local name=`basename "$path"`
    if [ -e "${name}-stamp" ]; then
        return
    fi
    local out_dir=$(fetch_unpack "https://github.com/${path}/archive/${tag_name}.tar.gz")
    (cd $out_dir \
        && ./configure --prefix=$BUILD_PREFIX $configure_args \
        && make -j4 \
        && make install)
    touch "${name}-stamp"
}

function build_openblas {
    if [ -e openblas-stamp ]; then return; fi
    if [ -n "$IS_OSX" ]; then
        # https://github.com/travis-ci/travis-ci/issues/8826
        brew cask uninstall oclint || echo "no oclint"
        brew install openblas
        brew link --force openblas
    else
        mkdir -p $ARCHIVE_SDIR
        local plat=${1:-${PLAT:-x86_64}}
        local tar_path=$(abspath $(_mb_get_gf_lib "openblas-${OPENBLAS_VERSION}" "$plat"))
        (cd / && tar zxf $tar_path)
    fi
    touch openblas-stamp
}

function build_zlib {
    # Gives an old but safe version
    if [ -n "$IS_OSX" ]; then return; fi  # OSX has zlib already
    if [ -e zlib-stamp ]; then return; fi
    yum install -y zlib-devel
    touch zlib-stamp
}

function build_new_zlib {
    # Careful, this one may cause yum to segfault
    # Fossils directory should also contain latest
    build_simple zlib $ZLIB_VERSION https://zlib.net/fossils
}

function build_jpeg {
    if [ -e jpeg-stamp ]; then return; fi
    fetch_unpack http://ijg.org/files/jpegsrc.v${JPEG_VERSION}.tar.gz
    (cd jpeg-${JPEG_VERSION} \
        && ./configure --prefix=$BUILD_PREFIX \
        && make -j4 \
        && make install)
    touch jpeg-stamp
}

function build_libpng {
    build_zlib
    build_simple libpng $LIBPNG_VERSION https://download.sourceforge.net/libpng
}

function build_bzip2 {
    if [ -n "$IS_OSX" ]; then return; fi  # OSX has bzip2 libs already
    if [ -e bzip2-stamp ]; then return; fi
    fetch_unpack https://download.sourceforge.net/bzip2/bzip2-${BZIP2_VERSION}.tar.gz
    (cd bzip2-${BZIP2_VERSION} \
        && make -f Makefile-libbz2_so \
        && make install PREFIX=$BUILD_PREFIX)
    touch bzip2-stamp
}

function build_tiff {
    build_zlib
    build_jpeg
    build_xz
    build_simple tiff $TIFF_VERSION https://download.osgeo.org/libtiff
}

function get_cmake {
    local cmake=cmake
    if [ -n "$IS_OSX" ]; then
        brew install cmake > /dev/null
    else
        yum install -y cmake28 > /dev/null
        cmake=cmake28
    fi
    echo $cmake
}

function build_openjpeg {
    if [ -e openjpeg-stamp ]; then return; fi
    build_zlib
    build_libpng
    build_tiff
    build_lcms2
    local cmake=$(get_cmake)
    local archive_prefix="v"
    if [ $(lex_ver $OPENJPEG_VERSION) -lt $(lex_ver 2.1.1) ]; then
        archive_prefix="version."
    fi
    local out_dir=$(fetch_unpack https://github.com/uclouvain/openjpeg/archive/${archive_prefix}${OPENJPEG_VERSION}.tar.gz)
    (cd $out_dir \
        && $cmake -DCMAKE_INSTALL_PREFIX=$BUILD_PREFIX . \
        && make install)
    touch openjpeg-stamp
}

function build_lcms2 {
    build_tiff
    build_simple lcms2 $LCMS2_VERSION https://downloads.sourceforge.net/project/lcms/lcms/$LCMS2_VERSION
}

function build_giflib {
    build_simple giflib $GIFLIB_VERSION https://downloads.sourceforge.net/project/giflib
}

function build_xz {
    build_simple xz $XZ_VERSION https://tukaani.org/xz
}

function build_libwebp {
    build_libpng
    build_tiff
    build_giflib
    build_simple libwebp $LIBWEBP_VERSION \
        https://storage.googleapis.com/downloads.webmproject.org/releases/webp tar.gz \
        --enable-libwebpmux --enable-libwebpdemux
}

function build_freetype {
    build_libpng
    build_bzip2
    build_simple freetype $FREETYPE_VERSION https://download.savannah.gnu.org/releases/freetype
}

function build_libyaml {
    build_simple yaml $LIBYAML_VERSION https://pyyaml.org/download/libyaml
}

function build_szip {
    # Build szip without encoding (patent restrictions)
    build_zlib
    build_simple szip $SZIP_VERSION \
        https://support.hdfgroup.org/ftp/lib-external/szip/$SZIP_VERSION/src tar.gz \
        --enable-encoding=no
}

function build_hdf5 {
    if [ -e hdf5-stamp ]; then return; fi
    build_zlib
    # libaec is a drop-in replacement for szip
    build_libaec
    local hdf5_url=https://support.hdfgroup.org/ftp/HDF5/releases
    local short=$(echo $HDF5_VERSION | awk -F "." '{printf "%d.%d", $1, $2}')
    fetch_unpack $hdf5_url/hdf5-$short/hdf5-$HDF5_VERSION/src/hdf5-$HDF5_VERSION.tar.gz
    (cd hdf5-$HDF5_VERSION \
        && ./configure --with-szlib=$BUILD_PREFIX --prefix=$BUILD_PREFIX \
        && make -j4 \
        && make install)
    touch hdf5-stamp
}

function build_libaec {
    if [ -e libaec-stamp ]; then return; fi
    local root_name=libaec-0.3.3
    local tar_name=${root_name}.tar.gz
    # Note URL will change for each version
    fetch_unpack https://gitlab.dkrz.de/k202009/libaec/uploads/48398bd5b7bc05a3edb3325abfeac864/${tar_name}
    (cd $root_name \
        && ./configure --prefix=$BUILD_PREFIX \
        && make \
        && make install)
    touch libaec-stamp
}

function build_blosc {
    if [ -e blosc-stamp ]; then return; fi
    local cmake=$(get_cmake)
    fetch_unpack https://github.com/Blosc/c-blosc/archive/v${BLOSC_VERSION}.tar.gz
    (cd c-blosc-${BLOSC_VERSION} \
        && $cmake -DCMAKE_INSTALL_PREFIX=$BUILD_PREFIX . \
        && make install)
    if [ -n "$IS_OSX" ]; then
        # Fix blosc library id bug
        for lib in $(ls ${BUILD_PREFIX}/lib/libblosc*.dylib); do
            install_name_tool -id $lib $lib
        done
    fi
    touch blosc-stamp
}

function build_snappy {
    build_simple snappy $SNAPPY_VERSION https://github.com/google/snappy/releases/download/$SNAPPY_VERSION
}

function build_lzo {
    if [ -e lzo-stamp ]; then return; fi
    fetch_unpack https://www.oberhumer.com/opensource/lzo/download/lzo-${LZO_VERSION}.tar.gz
    (cd lzo-${LZO_VERSION} \
        && ./configure --prefix=$BUILD_PREFIX --enable-shared \
        && make \
        && make install)
    touch lzo-stamp
}

function build_lzf {
    build_simple liblzf $LZF_VERSION http://dist.schmorp.de/liblzf
}

function build_curl {
    if [ -e curl-stamp ]; then return; fi
    local flags="--prefix=$BUILD_PREFIX"
    if [ -n "$IS_OSX" ]; then
        flags="$flags --with-darwinssl"
    else  # manylinux
        flags="$flags --with-ssl"
        build_openssl
    fi
    fetch_unpack https://curl.haxx.se/download/curl-${CURL_VERSION}.tar.gz
    (cd curl-${CURL_VERSION} \
        && if [ -z "$IS_OSX" ]; then \
        LIBS=-ldl ./configure $flags; else \
        ./configure $flags; fi\
        && make -j4 \
        && make install)
    touch curl-stamp
}

function check_sha256sum {
    local fname=$1
    if [ -z "$fname" ]; then echo "Need path"; exit 1; fi
    local sha256=$2
    if [ -z "$sha256" ]; then echo "Need SHA256 hash"; exit 1; fi
    echo "${sha256}  ${fname}" > ${fname}.sha256
    if [ -n "$IS_OSX" ]; then
        shasum -a 256 -c ${fname}.sha256
    else
        sha256sum -c ${fname}.sha256
    fi
    rm ${fname}.sha256
}

function build_openssl {
    if [ -e openssl-stamp ]; then return; fi
    fetch_unpack ${OPENSSL_DOWNLOAD_URL}/${OPENSSL_ROOT}.tar.gz
    check_sha256sum $ARCHIVE_SDIR/${OPENSSL_ROOT}.tar.gz ${OPENSSL_HASH}
    (cd ${OPENSSL_ROOT} \
        && ./config no-ssl2 no-shared -fPIC --prefix=$BUILD_PREFIX \
        && make -j4 \
        && make install)
    touch openssl-stamp
}

function build_netcdf {
    if [ -e netcdf-stamp ]; then return; fi
    build_hdf5
    build_curl
    fetch_unpack https://github.com/Unidata/netcdf-c/archive/v${NETCDF_VERSION}.tar.gz
    (cd netcdf-c-${NETCDF_VERSION} \
        && ./configure --prefix=$BUILD_PREFIX --enable-dap \
        && make -j4 \
        && make install)
    touch netcdf-stamp
}

function build_pcre {
    build_simple pcre $PCRE_VERSION https://ftp.pcre.org/pub/pcre
}

function build_swig {
    if [ -e swig-stamp ]; then return; fi
    if [ -n "$IS_OSX" ]; then
        brew install swig > /dev/null
    else
        build_pcre
        build_simple swig $SWIG_VERSION https://prdownloads.sourceforge.net/swig
    fi
    touch swig-stamp
}

function build_suitesparse {
    if [ -e suitesparse-stamp ]; then return; fi
    if [ -n "$IS_OSX" ]; then
        brew install suite-sparse > /dev/null
    else
        yum install -y suitesparse-devel > /dev/null
    fi
    touch suitesparse-stamp
}

function build_libtool {
    build_simple libtool $LIBTOOL_VERSION https://ftp.gnu.org/gnu/libtool
}

function build_ragel {
    build_simple ragel $RAGEL_VERSION https://www.colm.net/files/ragel
}

function build_bison {
    build_simple bison $BISON_VERSION https://ftp.gnu.org/gnu/bison
}

function build_flex {
    # the flex repository's git tags have a 'v' prefix
    build_simple flex $FLEX_VERSION \
        https://github.com/westes/flex/releases/download/v$FLEX_VERSION
}

function build_fftw_case {
    local configure_args=${@:0}

    build_simple fftw $FFTW_VERSION \
        http://www.fftw.org tar.gz \
        --with-pic --enable-shared --enable-threads --disable-fortran \
        $configure_args
    # eval cd fftw-$FFTW_VERSION/tests && make check-local && cd -
}

function build_fftw {
    echo 'Building fftw'

    # Save off current CFLAGS
    local old_cflags=$CFLAGS

    # Taken from: https://github.com/conda-forge/fftw-feedstock/blob/master/recipe/build.sh
    export CFLAGS="-O3 -fomit-frame-pointer -fstrict-aliasing -ffast-math"

    # single
    echo 'Building fftw: single'
    build_fftw_case --enable-float --enable-sse --enable-sse2 --enable-avx

    # Clear stamp file which prevents subsequent builds
    rm fftw-stamp

    # double
    echo 'Building fftw: double'
    build_fftw_case --enable-sse2 --enable-avx

    # Clear stamp file which prevents subsequent builds
    rm fftw-stamp

    # long double (SSE2 and AVX not supported)
    echo 'Building fftw: long double'
    build_fftw_case --enable-long-double

    # Taken from: https://github.com/conda-forge/pyfftw-feedstock/blob/master/recipe/build.sh
    export C_INCLUDE_PATH=$BUILD_PREFIX/include  # required as fftw3.h installed here

    # define STATIC_FFTW_DIR so the patched setup.py will statically link FFTW
    export STATIC_FFTW_DIR=$BUILD_PREFIX/lib

    # TODO: These can be made into asserts per:
    # https://github.com/conda-forge/fftw-feedstock/blob/8eaa8a1c63e7fcb97c63c1ee8e33c62ef3afa9c7/recipe/meta.yaml#L29-L52
    ls -l $C_INCLUDE_PATH/fftw3*
    ls -l $STATIC_FFTW_DIR/libfftw3*

    # restore CFLAGS
    export CFLAGS=$old_cflags
}

function build_cfitsio {
    if [ -e cfitsio-stamp ]; then return; fi
    if [ -n "$IS_OSX" ]; then
        brew install cfitsio
    else
        # cannot use build_simple because cfitsio has no dash between name and version
        local cfitsio_name_ver=cfitsio${CFITSIO_VERSION}
        fetch_unpack https://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/${cfitsio_name_ver}.tar.gz
        (cd cfitsio \
            && ./configure --prefix=$BUILD_PREFIX \
            && make shared && make install)
    fi
    touch cfitsio-stamp
}
