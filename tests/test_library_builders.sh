# Test some library builders
# Smoke test
export BUILD_PREFIX="${PWD}/builds"
rm_mkdir $BUILD_PREFIX
source library_builders.sh

build_openssl

[ "$STAMP_DIR" == $PWD ] || ingest
rm -f foo-stamp
stamped foo && ingest
stamp foo
[ -e foo-stamp ] || ingest
stamped foo || ingest
rm foo-stamp
stamped foo && ingest
touch foo-stamp
stamped foo || ingest
rm foo-stamp
