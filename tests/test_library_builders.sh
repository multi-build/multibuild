# Test some library builders
# Smoke test
export BUILD_PREFIX="${PWD}/builds"
rm_mkdir $BUILD_PREFIX
source library_builders.sh

function suppress {
    # Suppress the output of a bash command unless it fails
    rm --force $TMPDIR/suppress.out 2> /dev/null
    $* 2>&1 > $TMPDIR/suppress.out || cat $TMPDIR/suppress.out
    rm $TMPDIR/suppress.out
}

suppress build_openssl
suppress build_libwebp
suppress build_szip
