# Test common_utils

[ "$(abspath foo)" == "$PWD/foo" ] || ingest "abspath foo"
[ "$(abspath foo/bar)" == "$PWD/foo/bar" ] || ingest "abspath foo/bar"
[ "$(abspath /foo)" == "/foo" ] || ingest "abspath /foo"
[ "$(relpath $PWD/foo)" == "foo" ] || ingest "relpath foo"
[ "$(relpath foo/bar foo)" == "bar" ] || ingest "relpath foo/bar"
[ "$(realpath /foo)" == "/foo" ] || ingest "realpath /foo"

[ "$(lex_ver 2)" == "002000000" ] || ingest "lex_ver 2"
[ "$(lex_ver 2.1)" == "002001000" ] || ingest "lex_ver 2.1"
[ "$(lex_ver 2.1.4)" == "002001004" ] || ingest "lex_ver 2.1.4"
[ "$(lex_ver 2.1.4rc1)" == "002001004" ] || ingest "lex_ver 2.1.4"

[ "$(unlex_ver 002000000)" == "2.0.0" ] || ingest "unlex_ver 002000000"
[ "$(unlex_ver 003002012)" == "3.2.12" ] || ingest "unlex_ver 003002012"
# Not octal
[ "$(unlex_ver 003044099)" == "3.44.99" ] || ingest "unlex_ver 003044099"
[ "$(unlex_ver 003543012)" == "3.543.12" ] || ingest "unlex_ver 003543012"
[ "$(unlex_ver 003543012abc)" == "3.543.12" ] || ingest "unlex_ver 003543012abc"

[ "$(strip_ver_suffix 3.4.0rc1)" == "3.4.0" ] || ingest "unlex_ver strip suff 1"
[ "$(strip_ver_suffix 3.24.12a4)" == "3.24.12" ] || ingest "unlex_ver strip suff 2"

[ "$(is_function abspath)" == "true" ] || ingest "is_function abspath"
[ "$(is_function foo)" == "" ] || ingest "is_function foo"
bar=baz
[ "$(is_function bar)" == "" ] || ingest "is_function bar"

# Check function is not run in is_function. Thanks to Andrew Murray.
function rmfile {
    rm testfile
}

touch testfile
[ "$(is_function rmfile)" == "true" ] || ingest "is_function rmfile"
[ -f testfile ] || ingest "testfile removed during isfunction check"
rm testfile

rm_mkdir tmp_dir
[ -d tmp_dir ] || ingest "tmp_dir does not exist"
touch tmp_dir/afile
rm_mkdir tmp_dir
[ -e tmp_dir/afile ] && ingest "tmp_dir/afile should have been deleted"
rmdir tmp_dir

# Test suppress command
function bad_cmd {
    echo bad
    return 1
}

function bad_mid_cmd {
    # Command returns 0, but errors in the middle
    echo ok for now
    false
    echo should be bad now
    return 0
}

function good_cmd {
    echo good
    return 0
}

# Store state of options including -e, -x
# https://stackoverflow.com/questions/14564746/in-bash-how-to-get-the-current-status-of-set-x?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
ORIG_OPTS=$-
set +ex
[ "$(suppress bad_cmd)" == "$(printf "Running bad_cmd\nbad")" ] \
    || ingest "suppress bad_cmd"
[ "$(suppress good_cmd)" == "Running good_cmd" ] \
    || ingest "suppress good_cmd"
[ "$(suppress bad_mid_cmd)" == "Running bad_mid_cmd" ] \
    || ingest "suppress bad_mid_cmd"
# Can't use pipes here, because of the effect on set -e behavior.
expected="$(printf "Running bad_cmd\nbad")"
actual="$(set -e; suppress bad_cmd)"
[ "$actual" == "$expected" ] || ingest "suppress bad_cmd set -e"
expected="$(printf "Running good_cmd")"
actual="$(set -e; suppress good_cmd)"
[ "$actual" == "$expected" ] || ingest "suppress good_cmd set -e"
expected="$(printf "Running bad_mid_cmd\nok for now")"
actual="$(set -e; suppress bad_mid_cmd)"
[ "$actual" == "$expected" ] || ingest "suppress bad_mid_cmd set -e"
# Reset options
set_opts $ORIG_OPTS

# On Linux docker containers in travis, can only be x86_64 or i686
[ "$(get_platform)" == x86_64 ] || [ "$(get_platform)" == i686 ] || exit 1

# Crudest possible check for get_distutils_platform
expected=$(python -c "import distutils.util as du; print(du.get_platform())")
[ "$(get_distutils_platform)" == "$expected" ] || ingest "bad distutils platform"
