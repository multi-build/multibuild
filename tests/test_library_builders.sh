# Test some library builders
# Smoke test
export BUILD_PREFIX="${PWD}/builds"
rm_mkdir $BUILD_PREFIX
source library_builders.sh

function suppress {
    # Suppress the output of a bash command unless it fails
    /bin/rm --force /tmp/suppress.out 2> /dev/null
    $* 2>&1 > /tmp/suppress.out || cat /tmp/suppress.out
    /bin/rm /tmp/suppress.out
}

suppress build_openssl
suppress build_libwebp
suppress build_szip
