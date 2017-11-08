# Test some library builders
# Smoke test
export BUILD_PREFIX="${PWD}/builds"
rm_mkdir $BUILD_PREFIX
source library_builders.sh

# set -e -x

function print_failure {
    cat $HOME/suppress.out 
    exit 1
}

function suppress {
    # Suppress the output of a bash command unless it fails
    rm -f $HOME/suppress.out 2> /dev/null || true
    $* 2>&1 > $HOME/suppress.out || print_failure
    rm $HOME/suppress.out
}

if [ "$TRAVIS_OS_NAME" == "osx" ]; then brew update; fi

suppress build_openssl
suppress build_openblas
suppress build_libwebp
suppress build_szip
suppress build_swig
suppress build_github fredrik-johansson/arb 2.11.1
