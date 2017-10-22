# Test some library builders
# Smoke test
export BUILD_PREFIX="${PWD}/builds"
rm_mkdir $BUILD_PREFIX
source library_builders.sh

set -e -x

function suppress {
    # Suppress the output of a bash command unless it fails
    rm --force $HOME/suppress.out 2> /dev/null || true
    $* 2>&1 > $HOME/suppress.out || cat $HOME/suppress.out
    rm $HOME/suppress.out
}

suppress build_openssl
suppress build_libwebp
suppress build_szip
