# Recipes for building some libaries
# We use system zlib by default - see build_new_zlib
ZLIB_VERSION="${ZLIB_VERSION:-1.2.8}"
LIBPNG_VERSION="${LIBPNG_VERSION:-1.6.21}"
BZIP2_VERSION="${BZIP2_VERSION:-1.0.6}"
FREETYPE_VERSION="${FREETYPE_VERSION:-2.6.3}"
TIFF_VERSION="${FREETYPE_VERSION:-4.0.6}"
OPENJPEG_VERSION="${OPENJPEG_VERSION:-2.1}"
LCMS2_VERSION="${LCMS2_VERSION:-2.7}"
GIFLIB_VERSION="${GIFLIB_VERSION:-5.1.3}"
LIBWEBP_VERSION="${LIBWEBP_VERSION:-0.5.0}"
XZ_VERSION="${XZ_VERSION:-5.2.2}"
LIBYAML_VERSION="${LIBYAML_VERSION:-0.1.5}"
OPENBLAS_VERSION="${OPENBLAS_VERSION:-0.2.18}"

# Get needed utilities
MULTIBUILD_DIR=$(dirname "${BASH_SOURCE[0]}")
source ${MULTIBUILD_DIR}/manylinux_utils.sh

function build_simple {
    local name=$1
    local version=$2
    local url=$3
    if [ -e "${name}-stamp" ]; then
        return
    fi
    local name_version="${name}-${version}"
    local targz=${name_version}.tar.gz
    curl -LO $url/$targz
    tar zxf $targz
    (cd $name_version && ./configure && make && make install)
    touch "${name}-stamp"
}

function build_openblas {
    if [ -e openblas-stamp ]; then return; fi
    git clone https://github.com/xianyi/OpenBLAS
    (cd OpenBLAS \
        && git checkout "v${OPENBLAS_VERSION}" \
        && make DYNAMIC_ARCH=1 USE_OPENMP=0 NUM_THREADS=64 > /dev/null \
        && make PREFIX=/usr/local/ install)
    touch openblas-stamp
}

function build_zlib {
    # Gives an old but safe version
    if [ -e zlib-stamp ]; then return; fi
    yum install -y zlib-devel
    touch zlib-stamp
}

function build_new_zlib {
    # Careful, this one may cause yum to segfault
    build_simple zlib $ZLIB_VERSION http://zlib.net
}

function build_jpeg {
    if [ -e jpeg-stamp ]; then return; fi
    curl -LO http://ijg.org/files/jpegsrc.v9b.tar.gz
    tar zxf jpegsrc.v9b.tar.gz
    (cd jpeg-9b && ./configure && make && make install)
    touch jpeg-stamp
}

function build_libpng {
    build_zlib
    build_simple libpng $LIBPNG_VERSION http://download.sourceforge.net/libpng
}

function build_bzip2 {
    if [ -e bzip2-stamp ]; then return; fi
    curl -LO http://bzip.org/${BZIP2_VERSION}/bzip2-${BZIP2_VERSION}.tar.gz
    tar zxf bzip2-${BZIP2_VERSION}.tar.gz
    (cd bzip2-${BZIP2_VERSION} && make -f Makefile-libbz2_so && make install)
    touch bzip2-stamp
}

function build_tiff {
    build_zlib
    build_jpeg
    build_openjpeg
    build_xz
    build_simple tiff $TIFF_VERSION ftp://ftp.remotesensing.org/pub/libtiff
}

function build_openjpeg {
    if [ -e openjpeg-stamp ]; then return; fi
    yum install -y cmake28
    curl -LO https://github.com/uclouvain/openjpeg/archive/version.${OPENJPEG_VERSION}.tar.gz
    tar zxf version.${OPENJPEG_VERSION}.tar.gz
    (cd openjpeg-version.${OPENJPEG_VERSION} && cmake28 . && make install)
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
    curl -LO https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-${LIBWEBP_VERSION}.tar.gz
    tar zxf libwebp-${LIBWEBP_VERSION}.tar.gz
    (cd libwebp-${LIBWEBP_VERSION} && \
        ./configure --enable-libwebpmux --enable-libwebpdemux && \
         make && make install)
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
