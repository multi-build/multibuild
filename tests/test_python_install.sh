# Some debug echoes
echo "Python on path: `which python`"
echo "Python cmd: $PYTHON_EXE"
echo "pip on path: $(which pip)"
echo "pip cmd: $PIP_CMD"
echo "virtualenv on path: $(which virtualenv)"
echo "virtualenv cmd: $VIRTUALENV_CMD"

# Check that a pip install puts scripts on path
# (Need setuptools >= 25.0.1 for delocate install).
$PIP_CMD install "setuptools>=25"
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
python_mm=$(echo $cpython_version | awk -F "." '{printf "%d.%d", $1, $2}')

# extract implementation prefix and version
if [[ "$MB_PYTHON_VERSION" =~ (pypy[0-9\.]*-)?([0-9\.]+) ]]; then
    _impl=${BASH_REMATCH[1]:-"cp"}
    requested_impl=${_impl:0:2}
    requested_version=${BASH_REMATCH[2]}
else
    ingest "Error parsing MB_PYTHON_VERSION=$MB_PYTHON_VERSION"
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
    if [[ $requested_impl == 'cp' ]]; then
        macpie_bin="$MACPYTHON_PY_PREFIX/$python_mm/bin"
        bin_name="python$python_mm"
    else  # pypy
        macpie_bin="$PWD/pypy$python_mm-v$implementer_version-osx64/bin"
        if [ "$(lex_ver $implementer_version)" -ge "$(lex_ver 7.3.2)" ]; then
            bin_name="pypy3"
        else
            bin_name="pypy"
        fi
    fi
    if [ "$PYTHON_EXE" != "$macpie_bin/$bin_name" ]; then
        ingest "Wrong macpython python cmd '$PYTHON_EXE'"
    fi
    if [ "$PIP_CMD" != "$PYTHON_EXE -m pip" ]; then
        ingest "Wrong macpython or pypy pip '$PIP_CMD'"
    fi
fi
