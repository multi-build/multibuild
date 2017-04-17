# Tests for OSX utils

# Test extension for downloaded Python.org installer
[ "$(pyinst_ext_for_version 2.7.8)" == dmg ] || ingest
[ "$(pyinst_ext_for_version 2.7.9)" == pkg ] || ingest
[ "$(pyinst_ext_for_version 2.7)" == pkg ] || ingest
[ "$(pyinst_ext_for_version 2)" == pkg ] || ingest
[ "$(pyinst_ext_for_version 3.3.5)" == dmg ] || ingest
[ "$(pyinst_ext_for_version 3.4.1)" == dmg ] || ingest
[ "$(pyinst_ext_for_version 3.4.2)" == pkg ] || ingest
[ "$(pyinst_ext_for_version 3.5.0)" == pkg ] || ingest
[ "$(pyinst_ext_for_version 3.3)" == dmg ] || ingest
[ "$(pyinst_ext_for_version 3.4)" == pkg ] || ingest
[ "$(pyinst_ext_for_version 3)" == pkg ] || ingest

# Test utilities for getting Python version versions
[ "$(get_py_digit)" == "${cpython_version:0:1}" ] || ingest
[ "$(get_py_mm)" == "${cpython_version:0:3}" ] || ingest
[ "$(get_py_mm_nodot)" == $(echo "${cpython_version:0:3}" | tr -d .) ] || \
    ingest

# Test pkg-config install
install_pkg_config
