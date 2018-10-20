# Tests for manylinux utils

# CPython path calculator
[ "$(cpython_path 2.7)" == "/opt/python/cp27-cp27mu" ] || ingest "cp 2.7"
[ "$(cpython_path 2.7 32)" == "/opt/python/cp27-cp27mu" ] || ingest "cp 2.7 32"
[ "$(cpython_path 2.7 16)" == "/opt/python/cp27-cp27m" ] || ingest "cp 2.7 16"
[ "$(cpython_path 3.4)" == "/opt/python/cp34-cp34m" ] || ingest "cp 3.4"
[ "$(cpython_path 3.4 32)" == "/opt/python/cp34-cp34m" ] || ingest "cp 3.4 32"
[ "$(cpython_path 3.4 16)" == "/opt/python/cp34-cp34m" ] || ingest "cp 3.4 16"
[ "$(cpython_path 3.5)" == "/opt/python/cp35-cp35m" ] || ingest "cp 3.5"
[ "$(cpython_path 3.5 32)" == "/opt/python/cp35-cp35m" ] || ingest "cp 3.5 32"
[ "$(cpython_path 3.5 16)" == "/opt/python/cp35-cp35m" ] || ingest "cp 3.5 16"
