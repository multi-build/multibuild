# Tests for manylinux utils

# CPython path calculator
[ "$(cpython_path 2.7)" == "/opt/python/cp27-cp27mu" ] || ingest "cp 2.7"
[ "$(cpython_path 2.7 32)" == "/opt/python/cp27-cp27mu" ] || ingest "cp 2.7 32"
[ "$(cpython_path 2.7 16)" == "/opt/python/cp27-cp27m" ] || ingest "cp 2.7 16"
[ "$(cpython_path 3.5)" == "/opt/python/cp35-cp35m" ] || ingest "cp 3.5"
[ "$(cpython_path 3.5 32)" == "/opt/python/cp35-cp35m" ] || ingest "cp 3.5 32"
[ "$(cpython_path 3.5 16)" == "/opt/python/cp35-cp35m" ] || ingest "cp 3.5 16"
[ "$(cpython_path 3.7)" == "/opt/python/cp37-cp37m" ] || ingest "cp 3.7"
[ "$(cpython_path 3.7 32)" == "/opt/python/cp37-cp37m" ] || ingest "cp 3.7 32"
[ "$(cpython_path 3.7 16)" == "/opt/python/cp37-cp37m" ] || ingest "cp 3.7 16"
[ "$(cpython_path 3.8)" == "/opt/python/cp38-cp38" ] || ingest "cp 3.8"
[ "$(cpython_path 3.8 32)" == "/opt/python/cp38-cp38" ] || ingest "cp 3.8 32"
[ "$(cpython_path 3.8 16)" == "/opt/python/cp38-cp38" ] || ingest "cp 3.8 16"