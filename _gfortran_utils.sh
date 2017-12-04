# Stripped-down version of bash utilities for use with gfortran

function _mb_get_gf_lib_for_suf {
    local suffix=$1
    local prefix=$2
    local plat=${3:-$PLAT}
    local uname=${4:-$(uname)}
    if [ -z "$prefix" ]; then echo Prefix not defined; exit 1; fi
    local fname="$prefix-${uname}-${plat}${suffix}.tar.gz"
    local out_fname="${ARCHIVE_SDIR}/$fname"
    if [ ! -e "$out_fname" ]; then
        curl -L "${GF_LIB_URL}/$fname" > $out_fname || (echo "Fetch failed"; exit 1)
    fi
    echo "$out_fname"
}

function _mb_get_gf_lib {
    # Get library with no suffix
    _mb_get_gf_lib_for_suf "" $@
}
