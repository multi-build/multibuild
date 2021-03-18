#!/bin/bash
# Useful utilities common across manylinux builds

MULTIBUILD_DIR=$(dirname "${BASH_SOURCE[0]}")
source $MULTIBUILD_DIR/common_utils.sh

function get_platform {
    # Report platform as given by uname
    python -c 'import platform; print(platform.uname()[4])'
}

function repair_wheelhouse {
	# Runs 'auditwheel repair' over all wheels in a directory
	# If the wheel is not renamed by the repair process,
	# then the original wheel will be left unmodified
    local in_dir=$1
    local out_dir=${2:-$in_dir}
    for whl in $in_dir/*.whl; do
        if [[ $whl == *none-any.whl ]]; then  # Pure Python wheel
            if [ "$in_dir" != "$out_dir" ]; then cp $whl $out_dir; fi
        else
            local tmpdir=$(mktemp -d -t)
            
            auditwheel repair $whl -w $tmpdir/
            
            local built=$(find $tmpdir -name *.whl)
            if [ $(basename $built) == $(basename $whl) ]; then
                if [ "$in_dir" != "$out_dir" ]; then cp $whl $out_dir; fi
            else
                cp $built $out_dir
                
                # Remove unfixed if writing into same directory
                if [ "$in_dir" == "$out_dir" ]; then rm $whl; fi
            fi
            rm -rf $tmpdir
        fi
    done
    chmod -R a+rwX $out_dir
}

function activate_ccache {
    # Link up the correct location for ccache
    mkdir -p /parent-home/.ccache
    ln -s /parent-home/.ccache $HOME/.ccache

    # Now install ccache
    if [[ $MB_ML_VER == "_2_24" ]]; then
        suppress apt-get install -y ccache
    else
        suppress yum_install ccache
    fi

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

function yum_install {
    # CentOS 5 yum doesn't fail in some cases, e.g. if package is not found
    # https://serverfault.com/questions/694942/yum-should-error-when-a-package-is-not-available
    yum install -y "$1" && rpm -q "$1"
}
