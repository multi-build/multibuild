# Test python version fill utility
[ "$(fill_pyver 2)" == $LATEST_2p7 ] || ingest
[ "$(fill_pyver 2.7)" == $LATEST_2p7 ] || ingest
[ "$(fill_pyver 2.7.8)" == "2.7.8" ] || ingest
[ "$(fill_pyver 3)" == $LATEST_3p7 ] || ingest
[ "$(fill_pyver 3.7.0)" == "3.7.0" ] || ingest
[ "$(fill_pyver 3.7)" == $LATEST_3p7 ] || ingest
[ "$(fill_pyver 3.6)" == $LATEST_3p6 ] || ingest
[ "$(fill_pyver 3.6.0)" == "3.6.0" ] || ingest
[ "$(fill_pyver 3.5)" == $LATEST_3p5 ] || ingest
[ "$(fill_pyver 3.5.0)" == "3.5.0" ] || ingest
[ "$(fill_pyver 3.4)" == $LATEST_3p4 ] || ingest
