# Find, load common utilties
# Defines IS_OSX, fetch_unpack
MULTIBUILD_DIR=$(dirname "${BASH_SOURCE[0]}")
source $MULTIBUILD_DIR/common_utils.sh

# Recipes for building some libaries
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
SZIP_VERSION="${SZIP_VERSION:-2.1}"
HDF5_VERSION="${HDF5_VERSION:-1.8.18}"
LIBAEC_VERSION="${LIBAEC_VERSION:-0.3.3}"
LZO_VERSION=${LZO_VERSION:-2.09}
LZF_VERSION="${LZF_VERSION:-3.6}"
BLOSC_VERSION=${BLOSC_VERSION:-1.10.2}
SNAPPY_VERSION="${SNAPPY_VERSION:-1.1.3}"
CURL_VERSION=${CURL_VERSION:-7.49.1}
NETCDF_VERSION=${NETCDF_VERSION:-4.4.1.1}
OPENSSL_ROOT=openssl-1.0.2l
# Hash from https://www.openssl.org/source/openssl-1.0.2?.tar.gz.sha256
OPENSSL_HASH=ce07195b659e75f4e1db43552860070061f156a98bb37b672b101ba6e3ddf30c
OPENSSL_DOWNLOAD_URL=https://www.openssl.org/source


BUILD_PREFIX="${BUILD_PREFIX:-/usr/local}"
ARCHIVE_SDIR=${ARCHIVE_DIR:-archives}

# Set default library compilation flags for OSX
# IS_OSX defined in common_utils.sh
if [ -n "$IS_OSX" ]; then
    # Dual arch build by default
    ARCH_FLAGS=${ARCH_FLAGS:-"-arch i386 -arch x86_64"}
    # Only set CFLAGS, FFLAGS if they are not already defined.  Build functions
    # can override the arch flags by setting CFLAGS, FFLAGS
    export CFLAGS="${CFLAGS:-$ARCH_FLAGS}"
    export CXXFLAGS="${CXXFLAGS:-$ARCH_FLAGS}"
    export FFLAGS="${FFLAGS:-$ARCH_FLAGS}"
fi

function build_simple {
    local name=$1
    local version=$2
    local url=$3
    local ext=${4:-tar.gz}
    if [ -e "${name}-stamp" ]; then
        return
    fi
    local name_version="${name}-${version}"
    local archive=${name_version}.${ext}
    fetch_unpack $url/$archive
    (cd $name_version \
        && ./configure --prefix=$BUILD_PREFIX \
        && make \
        && make install)
    touch "${name}-stamp"
}

function build_openblas {
    if [ -e openblas-stamp ]; then return; fi
    if [ -d "OpenBLAS" ]; then
        (cd OpenBLAS && git clean -fxd && git reset --hard)
    else
        git clone https://github.com/xianyi/OpenBLAS
    fi
    (cd OpenBLAS \
        && git checkout "v${OPENBLAS_VERSION}" \
        && make DYNAMIC_ARCH=1 USE_OPENMP=0 NUM_THREADS=64 > /dev/null \
        && make PREFIX=$BUILD_PREFIX install)
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
    build_simple zlib $ZLIB_VERSION http://zlib.net/fossils
}

function build_jpeg {
    if [ -e jpeg-stamp ]; then return; fi
    fetch_unpack http://ijg.org/files/jpegsrc.v${JPEG_VERSION}.tar.gz
    (cd jpeg-${JPEG_VERSION} \
        && ./configure --prefix=$BUILD_PREFIX \
        && make \
        && make install)
    touch jpeg-stamp
}

function build_libpng {
    build_zlib
    build_simple libpng $LIBPNG_VERSION http://download.sourceforge.net/libpng
}

function build_bzip2 {
    if [ -n "$IS_OSX" ]; then return; fi  # OSX has bzip2 libs already
    if [ -e bzip2-stamp ]; then return; fi
    fetch_unpack http://bzip.org/${BZIP2_VERSION}/bzip2-${BZIP2_VERSION}.tar.gz
    (cd bzip2-${BZIP2_VERSION} \
        && make -f Makefile-libbz2_so \
        && make install PREFIX=$BUILD_PREFIX)
    touch bzip2-stamp
}

function build_tiff {
    build_zlib
    build_jpeg
    build_xz
    build_simple tiff $TIFF_VERSION http://download.osgeo.org/libtiff
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
    fetch_unpack https://github.com/uclouvain/openjpeg/archive/${archive_prefix}${OPENJPEG_VERSION}.tar.gz
    (cd openjpeg-version.${OPENJPEG_VERSION} \
        && $cmake -DCMAKE_INSTALL_PREFIX=$BUILD_PREFIX . \
        && make install)
    touch openjpeg-stamp
}

function build_lcms2 {
    build_tiff
    build_simple lcms2 $LCMS2_VERSION http://downloads.sourceforge.net/project/lcms/lcms/$LCMS2_VERSION
}

function build_giflib {
    build_simple giflib $GIFLIB_VERSION http://downloads.sourceforge.net/project/giflib
}

function build_xz {
    build_simple xz $XZ_VERSION http://tukaani.org/xz
}

function build_libwebp {
    if [ -e libwebp-stamp ]; then return; fi
    build_libpng
    build_tiff
    build_giflib
    fetch_unpack https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-${LIBWEBP_VERSION}.tar.gz
    (cd libwebp-${LIBWEBP_VERSION} && \
        ./configure --enable-libwebpmux --enable-libwebpdemux --prefix=$BUILD_PREFIX \
        && make \
        && make install)
    touch libwebp-stamp
}

function build_freetype {
    build_libpng
    build_bzip2
    build_simple freetype $FREETYPE_VERSION http://download.savannah.gnu.org/releases/freetype
}

function build_libyaml {
    build_simple yaml $LIBYAML_VERSION http://pyyaml.org/download/libyaml
}

function build_szip {
    # Build szip without encoding (patent restrictions)
    if [ -e szip-stamp ]; then return; fi
    build_zlib
    local szip_url=https://www.hdfgroup.org/ftp/lib-external/szip/
    fetch_unpack ${szip_url}/$SZIP_VERSION/src/szip-$SZIP_VERSION.tar.gz
    (cd szip-$SZIP_VERSION \
        && ./configure --enable-encoding=no --prefix=$BUILD_PREFIX \
        && make \
        && make install)
    touch szip-stamp
}

function build_hdf5 {
    if [ -e hdf5-stamp ]; then return; fi
    build_zlib
    # libaec is a drop-in replacement for szip
    build_libaec
    local hdf5_url=https://www.hdfgroup.org/ftp/HDF5/releases
    local short=$(echo $HDF5_VERSION | awk -F "." '{printf "%d.%d", $1, $2}')
    fetch_unpack $hdf5_url/hdf5-$short/hdf5-$HDF5_VERSION/src/hdf5-$HDF5_VERSION.tar.gz
    (cd hdf5-$HDF5_VERSION \
        && ./configure --with-szlib=$BUILD_PREFIX --prefix=$BUILD_PREFIX \
        && make \
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
    fetch_unpack http://www.oberhumer.com/opensource/lzo/download/lzo-${LZO_VERSION}.tar.gz
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
        && make \
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
        && make \
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
        && make \
        && make install)
    touch netcdf-stamp
}
