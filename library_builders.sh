#Functions and environment variables to build various
#native libraries commonly used as dependencies

MULTIBUILD_DIR=$(dirname "${BASH_SOURCE[0]}")
source $MULTIBUILD_DIR/_gfortran_utils.sh
source $MULTIBUILD_DIR/configure_build.sh

# For OpenBLAS
GF_LIB_URL="https://3f23b170c54c2533c070-1c8a9b3114517dc5fe17b7c3f8c63a43.ssl.cf2.rackcdn.com"

function set_lib_version_hash {
    # set variables with version and hash if not set previously. If version is already set, do not
    # try to set/modify hash, as this might usually result in hash mismatch
    local name=$1
    local version=$2
    local sha256_hash=$3
    local version_var="${name}_VERSION"
    local hash_var="${name}_HASH"
    if [ -z "${!version_var}" ] ; then
	# set variable using printf, declare doesn't support -g in Centos 5/6
	printf -v "${version_var}" '%s' "${version}"
        if [ -n "${sha256_hash}" ] ; then
	  printf -v "${hash_var}" '%s' "${sha256_hash}"
        fi
    fi
}

# Recipes for building some libraries
# To set different version set <LIBRARY>_VERSION and <LIBRARY>_HASH variables or use set_lib_version_hash
# as below. For example to change LIBPNG version use LIBPNG_VERSION and LIBPNG_HASH variables. The latter
# is optional and if not provided hash will not be checked

# no hash for openblas as it's downloading binaries and they are platform dependant
set_lib_version_hash OPENBLAS "0.2.18"
# We use system zlib by default - see build_new_zlib
set_lib_version_hash ZLIB     "1.2.10"  "8d7e9f698ce48787b6e1c67e6bff79e487303e66077e25cb9784ac8835978017"
set_lib_version_hash LIBPNG   "1.6.21"  "b36a3c124622c8e1647f360424371394284f4c6c4b384593e478666c59ff42d3"
set_lib_version_hash BZIP2    "1.0.6"   "a2848f34fcd5d6cf47def00461fcb528a0484d8edef8208d6d2e2909dc61d9cd"
set_lib_version_hash FREETYPE "2.6.3"   "7942096c40ee6fea882bd4207667ad3f24bff568b96b10fd3885e11a7baad9a3"
set_lib_version_hash TIFF     "4.1.0"   "5d29f32517dadb6dbcd1255ea5bbc93a2b54b94fbf83653b4d65c7d6775b8634"
set_lib_version_hash JPEG     "9b"      "240fd398da741669bf3c90366f58452ea59041cacc741a489b99f2f6a0bad052"
set_lib_version_hash OPENJPEG "2.1"     "4afc996cd5e0d16360d71c58216950bcb4ce29a3272360eb29cadb1c8bce4efc"
set_lib_version_hash LCMS2    "2.9"     "48c6fdf98396fa245ed86e622028caf49b96fa22f3e5734f853f806fbc8e7d20"
set_lib_version_hash GIFLIB   "5.1.3"   "21d73688f54f881cdf1393acbc9af2fe9b3be54d53ace6f5a11c8c3a4646bd01"
set_lib_version_hash LIBWEBP  "0.5.0"   "5cd3bb7b623aff1f4e70bd611dc8dbabbf7688fd5eb225b32e02e09e37dfb274"
set_lib_version_hash XZ       "5.2.2"   "73df4d5d34f0468bd57d09f2d8af363e95ed6cc3a4a86129d2f2c366259902a2"
# change of version in LIBAEC not supported, see build_libaec
set_lib_version_hash LIBAEC   "1.0.4"   "f2b1b232083bd8beaf8a54a024225de3dd72a673a9bcdf8c3ba96c39483f4309"
set_lib_version_hash LIBYAML  "0.2.2"   "4a9100ab61047fd9bd395bcef3ce5403365cafd55c1e0d0299cde14958e47be9"
set_lib_version_hash SZIP     "2.1.1"   "21ee958b4f2d4be2c9cabfa5e1a94877043609ce86fde5f286f105f7ff84d412"
set_lib_version_hash HDF5     "1.10.5"  "6d4ce8bf902a97b050f6f491f4268634e252a63dadd6656a1a9be5b7b7726fa8"
set_lib_version_hash LZO      "2.10"    "c0f892943208266f9b6543b3ae308fab6284c5c90e627931446fb49b4221a072"
set_lib_version_hash LZF      "3.6"     "9c5de01f7b9ccae40c3f619d26a7abec9986c06c36d260c179cedd04b89fb46a"
set_lib_version_hash BLOSC    "1.10.2"  "c8ea29677056dd8a3d27929b4490a339b9516ca3562f3d50a1c84bab109bb278"
set_lib_version_hash SNAPPY   "1.1.3"   "2f1e82adf0868c9e26a5a7a3115111b6da7e432ddbac268a7ca2fae2a247eef3"
set_lib_version_hash CURL     "7.49.1"  "ff3e80c1ca6a068428726cd7dd19037a47cc538ce58ef61c59587191039b2ca6"
set_lib_version_hash NETCDF   "4.4.1.1" "7f040a0542ed3f6d27f3002b074e509614e18d6c515b2005d1537fec01b24909"
set_lib_version_hash SWIG     "4.0.1"   "7a00b4d0d53ad97a14316135e2d702091cd5f193bb58bcfcd8bc59d41e7887a9"
set_lib_version_hash PCRE     "8.38"    "9883e419c336c63b0cb5202b09537c140966d585e4d0da66147dc513da13e629"
set_lib_version_hash LIBTOOL  "2.4.6"   "e3bd4d5d3d025a36c21dd6af7ea818a2afcd4dfc1ea5a17b39d7854bcd0c06e3"
set_lib_version_hash RAGEL    "6.10"    "5f156edb65d20b856d638dd9ee2dfb43285914d9aa2b6ec779dac0270cd56c3f"
set_lib_version_hash FLEX     "2.6.4"   "e87aae032bf07c26f85ac0ed3250998c37621d95f8bd748b31f15b33c45ee995"
set_lib_version_hash BISON    "3.0.4"   "b67fd2daae7a64b5ba862c66c07c1addb9e6b1b05c5f2049392cfd8a2172952e"
set_lib_version_hash FFTW     "3.3.7"   "3b609b7feba5230e8f6dd8d245ddbefac324c5a6ae4186947670d9ac2cd25573"
set_lib_version_hash CFITSIO  "3450"    "bf6012dbe668ecb22c399c4b7b2814557ee282c74a7d5dc704eb17c30d9fb92e"
set_lib_version_hash OPENSSL  "1.0.2u"  "ecd0c6ffb493dd06707d38b14bb4d8c2288bb7033735606569d8f90f89669d16"


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
        brew install openblas
        brew link --force openblas
    elif [ ! -v IS_X86 ]; then
		# Skip this for now until we can build a suitable tar.gz
        return;
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
    yum_install zlib-devel
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
    fetch_unpack https://sourceware.org/pub/bzip2/bzip2-${BZIP2_VERSION}.tar.gz
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
        yum_install cmake28 > /dev/null
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
        --enable-threadsafe --enable-unsupported --with-pthread=yes \
        && make -j4 \
        && make install)
    touch hdf5-stamp
}

function build_libaec {
    if [ -e libaec-stamp ]; then return; fi
    local root_name=libaec-1.0.4
    local tar_name=${root_name}.tar.gz
    # Note URL will change for each version
    fetch_unpack https://gitlab.dkrz.de/k202009/libaec/uploads/ea0b7d197a950b0c110da8dfdecbb71f/${tar_name}
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
        yum_install suitesparse-devel > /dev/null
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
