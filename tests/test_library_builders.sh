# Test some library builders
# Smoke test
export BUILD_PREFIX="${PWD}/builds"
rm_mkdir $BUILD_PREFIX
source library_builders.sh

function surpress {
    # Suppress the output of a bash command unless it fails
    /bin/rm --force /tmp/surpress.out 2> /dev/null
    $* 2>&1 > /tmp/surpress.out || cat /tmp/surpress.out
    /bin/rm /tmp/surpress.out
}

suppress build_openssl
suppress build_libwebp
suppress build_szip
