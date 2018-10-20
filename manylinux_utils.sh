#!/bin/bash
# Useful utilities common across manylinux1 builds

MULTIBUILD_DIR=$(dirname "${BASH_SOURCE[0]}")
source $MULTIBUILD_DIR/common_utils.sh

# UNICODE_WIDTH selects "32"=wide (UCS4) or "16"=narrow (UCS2/UTF16) builds
UNICODE_WIDTH="${UNICODE_WIDTH:-32}"

function get_platform {
    # Report platform as given by uname
    python -c 'import platform; print(platform.uname()[4])'
}

function cpython_path {
    # Return path to cpython given
    # * version (of form "2.7")
    # * u_width ("16" or "32" default "32")
    #
    # For back-compatibility "u" as u_width also means "32"
    local py_ver="${1:-2.7}"
    local u_width="${2:-${UNICODE_WIDTH}}"
    local u_suff=u
    # Back-compatibility
    if [ "$u_width" == "u" ]; then u_width=32; fi
    # For Python >= 3.4, "u" suffix not meaningful
    if [ $(lex_ver $py_ver) -ge $(lex_ver 3.4) ] ||
        [ "$u_width" == "16" ]; then
        u_suff=""
    elif [ "$u_width" != "32" ]; then
        echo "Incorrect u_width value $u_width"
        exit 1
    fi
    local no_dots=$(echo $py_ver | tr -d .)
    echo "/opt/python/cp${no_dots}-cp${no_dots}m${u_suff}"
}

function repair_wheelhouse {
    local in_dir=$1
    local out_dir=${2:-$in_dir}
    for whl in $in_dir/*.whl; do
        if [[ $whl == *none-any.whl ]]; then  # Pure Python wheel
            if [ "$in_dir" != "$out_dir" ]; then cp $whl $out_dir; fi
        else
            auditwheel repair $whl -w $out_dir/
            # Remove unfixed if writing into same directory
            if [ "$in_dir" == "$out_dir" ]; then rm $whl; fi
        fi
    done
    chmod -R a+rwX $out_dir
}

function activate_ccache {
    # Link up the correct location for ccache
    mkdir -p /parent-home/.ccache
    ln -s /parent-home/.ccache $HOME/.ccache

    # Now install ccache
    suppress yum install -y ccache

    # Create fake compilers and prepend them to the PATH
    # Note that yum is supposed to create these for us,
    # but I had trouble finding them
    local ccache_dir=/usr/lib/ccache/compilers
    mkdir -p $ccache_dir
    ln -s /usr/bin/ccache $ccache_dir/gcc
    ln -s /usr/bin/ccache $ccache_dir/g++
    ln -s /usr/bin/ccache $ccache_dir/cc
    ln -s /usr/bin/ccache $ccache_dir/c++
    export PATH=$ccache_dir:$PATH

    # Prove to the developer that ccache is activated
    echo "Using C compiler: $(which gcc)"
}
