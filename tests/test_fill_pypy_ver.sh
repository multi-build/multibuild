# Test Python version fill utility, for pypy
[ "$(fill_pypy_ver 4)" == $LATEST_PP_4 ] || ingest "lpp4"
[ "$(fill_pypy_ver 5)" == $LATEST_PP_5 ] || ingest "lpp5"
[ "$(fill_pypy_ver 6)" == $LATEST_PP_6 ] || ingest "lpp6"
[ "$(fill_pypy_ver 4.0)" == $LATEST_PP_4p0 ] || ingest
[ "$(fill_pypy_ver 5.0)" == $LATEST_PP_5p0 ] || ingest
[ "$(fill_pypy_ver 5.1)" == $LATEST_PP_5p1 ] || ingest
[ "$(fill_pypy_ver 5.3)" == $LATEST_PP_5p3 ] || ingest
[ "$(fill_pypy_ver 5.4)" == $LATEST_PP_5p4 ] || ingest
[ "$(fill_pypy_ver 5.6)" == $LATEST_PP_5p6 ] || ingest
[ "$(fill_pypy_ver 5.7)" == $LATEST_PP_5p7 ] || ingest
[ "$(fill_pypy_ver 5.8)" == $LATEST_PP_5p8 ] || ingest
[ "$(fill_pypy_ver 5.9)" == $LATEST_PP_5p9 ] || ingest
[ "$(fill_pypy_ver 5.10)" == $LATEST_PP_5p10 ] || ingest
[ "$(fill_pypy_ver 6.0)" == $LATEST_PP_6p0 ] || ingest
[ "$(fill_pypy_ver 4.0.1)" == "4.0.1" ] || ingest
[ "$(fill_pypy_ver 5.0.1)" == "5.0.1" ] || ingest
