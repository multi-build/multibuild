# Tests for OSX utils

# Test extension for downloaded Python.org installer
[ "$(pyinst_ext_for_version 2.7.8)" == dmg ] || ingest
[ "$(pyinst_ext_for_version 2.7.9)" == pkg ] || ingest
[ "$(pyinst_ext_for_version 2.7)" == pkg ] || ingest
[ "$(pyinst_ext_for_version 2)" == pkg ] || ingest
[ "$(pyinst_ext_for_version 3.5.0)" == pkg ] || ingest
[ "$(pyinst_ext_for_version 3.5)" == pkg ] || ingest
[ "$(pyinst_ext_for_version 3)" == pkg ] || ingest

[ "$(pyinst_fname_for_version 2.7.14)" == "python-2.7.14-macosx10.6.pkg" ] || ingest
[ "$(pyinst_fname_for_version 2.7.15)" == "python-2.7.15-macosx10.9.pkg" ] || ingest
[ "$(pyinst_fname_for_version 3.6.8)" == "python-3.6.8-macosx10.9.pkg" ] || ingest
[ "$(pyinst_fname_for_version 3.7.1)" == "python-3.7.1-macosx10.9.pkg" ] || ingest
[ "$(pyinst_fname_for_version 3.8.0)" == "python-3.8.0-macosx10.9.pkg" ] || ingest

[ "$(pyinst_fname_for_version 2.7.14 10.6)" == "python-2.7.14-macosx10.6.pkg" ] || ingest
[ "$(pyinst_fname_for_version 2.7.15 10.6)" == "python-2.7.15-macosx10.6.pkg" ] || ingest
[ "$(pyinst_fname_for_version 3.6.8 10.6)" == "python-3.6.8-macosx10.6.pkg" ] || ingest
[ "$(pyinst_fname_for_version 3.7.1 10.6)" == "python-3.7.1-macosx10.6.pkg" ] || ingest

[ "$(pyinst_fname_for_version 2.7.15 10.11)" == "python-2.7.15-macosx10.11.pkg" ] || ingest
[ "$(pyinst_fname_for_version 3.7.1 10.12)" == "python-3.7.1-macosx10.12.pkg" ] || ingest

# Test utilities for getting Python version versions
[ "$(get_py_digit)" == "${cpython_version:0:1}" ] || ingest
[ "$(get_py_mm)" == "${cpython_version:0:3}" ] || ingest
[ "$(get_py_mm_nodot)" == $(echo "${cpython_version:0:3}" | tr -d .) ] || ingest

# test lookup of arch from Python macOS target build
[ "$(macpython_arch_for_version 2.7 10.6)" == "intel" ] || ingest
[ "$(macpython_arch_for_version 2.7 10.9)" == "x86_64" ] || ingest
[ "$(macpython_arch_for_version pypy-2.7)" == "x86_64" ] || ingest
[ "$(macpython_arch_for_version 3.10 11.0)" == "arm64" ] || ingest

# test lookup of arch / min macOS versions from installed Python distutils tag
[ "$(get_macpython_arch macosx-10.6-intel)" == "intel" ] || ingest
[ "$(get_macpython_arch macosx-10.6-x86_64)" == "x86_64" ] || ingest
[ "$(get_macpython_osx_ver macosx-10.6-intel)" == "10.6" ] || ingest

# test utilities for extracting version and impl from Python version string
[ "$(strip_macpython_ver_prefix 3.7.2)" == "3.7.2" ] || ingest
[ "$(strip_macpython_ver_prefix pypy-5.4)" == "5.4" ] || ingest
[ "$(macpython_impl_for_version 3.7.2)" == "cp" ] || ingest
[ "$(macpython_impl_for_version pypy-5.4)" == "pp" ] || ingest

# Test lookup of available macOS SDK build targets from python version
if [ "$(uname -m)" != "arm64" ]; then
  [ "$(macpython_sdk_list_for_version 3.8)"    == "10.9" ] || ingest
  [ "$(macpython_sdk_list_for_version 3.7.5)"  == "10.6 10.9" ] || ingest
  [ "$(macpython_sdk_list_for_version 3.7)"    == "10.6 10.9" ] || ingest
  [ "$(macpython_sdk_list_for_version 3.6.5)"  == "10.6 10.9" ] || ingest
  [ "$(macpython_sdk_list_for_version 3.6)"    == "10.6 10.9" ] || ingest
  [ "$(macpython_sdk_list_for_version 3.5)"    == "10.6" ] || ingest
  [ "$(macpython_sdk_list_for_version 2.7)"    == "10.9" ] || ingest
  [ "$(macpython_sdk_list_for_version 2.7.14)" == "10.6" ] || ingest
  [ "$(macpython_sdk_list_for_version 2.7.15)" == "10.6 10.9" ] || ingest
  [ "$(macpython_sdk_list_for_version 2.7.17)" == "10.6 10.9" ] || ingest
  [ "$(macpython_sdk_list_for_version 2.7.18)" == "10.9" ] || ingest
fi
(PLAT="arm64";      [ "$(macpython_sdk_for_version 3.9)" == "11.0" ] || ingest)
(PLAT="universal2"; [ "$(macpython_sdk_for_version 3.9)" == "10.9" ] || ingest)
(PLAT="x86_64";     [ "$(macpython_sdk_for_version 3.9)" == "10.9" ] || ingest)
if [ "$(uname -m)" != "arm64" ]; then
  [ "$(macpython_sdk_for_version 3.9)"    == "10.9" ] || ingest
  [ "$(macpython_sdk_for_version 3.8)"    == "10.9" ] || ingest
  [ "$(macpython_sdk_for_version 3.5)"    == "10.6" ] || ingest
  [ "$(macpython_sdk_for_version 2.7)"    == "10.9" ] || ingest
  [ "$(macpython_sdk_for_version 2.7.14)" == "10.6" ] || ingest
fi

# Test pkg-config install
install_pkg_config

function echo_host_platform {
    echo $_PYTHON_HOST_PLATFORM
}

# Make sure `_PYTHON_HOST_PLATFORM` is set when building x86_64 thin wheel
if [ "$(uname -m)" != "arm64" ]; then
  (PLAT="x86_64"; MB_PYTHON_OSX_VER="10.9"; [ "$(wrap_wheel_builder echo_host_platform)" == "macosx-10.9-x86_64" ])
fi
