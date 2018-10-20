# Some debug echoes
echo "Python on path: `which python`"
echo "Python cmd: $PYTHON_EXE"
echo "pip on path: $(which pip)"
echo "pip cmd: $PIP_CMD"
echo "virtualenv on path: $(which virtualenv)"
echo "virtualenv cmd: $VIRTUALENV_CMD"

# Check that a pip install puts scripts on path
# (Need setuptools >= 25.0.1 for delocate install).
pip install "setuptools>=25"
install_delocate
delocate-listdeps --version || ingest "Delocate not installed right"

# Python version from Python to compare against required
if [[ $($PYTHON_EXE --version 2>&1 | awk '{print $2}') =~ ([0-9.]*).?([0-9.]*) ]]
then
    # CPython version, 2.7.x on both CPython 2.7 and PyPy 5.4
    cpython_version=${BASH_REMATCH[1]}
    # CPython/PyPy version
    implementer_version=${BASH_REMATCH[2]:-$cpython_version}
fi
python_mm="${cpython_version:0:1}.${cpython_version:2:1}"

# Remove implementation prefix
if [[ "$PYTHON_VERSION" =~ (pypy-)?([0-9\.]+) ]]; then
    requested_version=${BASH_REMATCH[2]}
else
    ingest "Error parsing PYTHON_VERSION=$PYTHON_VERSION"
fi

# simple regex match, a 2.7 pattern will match 2.7.11, but not 2
if ! [[ "$implementer_version" =~ $requested_version ]]; then
    ingest "Wrong python version: ${implementer_version}!=${requested_version}"
fi

if [ -n "$VENV" ]; then  # in virtualenv
    # Correct pip and Python versions should be on PATH
    if [ "$($PYTHON_EXE --version 2>&1)" != "$(python --version 2>&1)" ]; then
        ingest "Python versions do not match"
    fi
    if [ "$($PIP_CMD --version)" != "$(pip --version)" ]; then
        ingest "Pip versions do not match"
    fi
    # Versions in environment variables have full path
    if [ "$PYTHON_EXE" != "$PWD/venv/bin/python" ]; then
        ingest "Wrong virtualenv python '$PYTHON_EXE'"
    fi
    if [ "$PIP_CMD" != "${PWD}/venv/bin/pip${expected_pip_args}" ]; then
        ingest "Wrong virtualenv pip '$PIP_CMD'"
    fi
else # not virtualenv
    macpie_bin="$MACPYTHON_PY_PREFIX/$python_mm/bin"
    if [ "$PYTHON_EXE" != "$macpie_bin/python$python_mm" ]; then
        ingest "Wrong macpython python cmd '$PYTHON_EXE'"
    fi
    if [ "$PIP_CMD" != "sudo $macpie_bin/pip${python_mm}${expected_pip_args}" ]; then
        ingest "Wrong macpython pip '$PIP_CMD'"
    fi
fi
