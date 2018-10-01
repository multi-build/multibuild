# Test supported wheels script
PYTHON_EXE=${PYTHON_EXE:-python}
if [ -z "$PIP_CMD" ]; then
    pip_install="pip install --user"
else
    pip_install="$PIP_CMD install"
fi
# Current wheel versions not available for older Pythons
lpv=$(lex_ver $PYTHON_VERSION)
if [ $lpv -ge $(lex_ver 3.5) ] || [ $lpv -lt $(lex_ver 3) ]; then
    for whl in wheel==0.31.1 wheel==0.32.0 wheel; do
        $pip_install -U $whl
        $PYTHON_EXE supported_wheels.py tornado-5.1-cp27-cp27m-macosx_10_6_intel.whl tornado-5.1-cp36-cp36m-macosx_10_13_x86_64.whl texext-0.6.1-cp36-none-any.whl
    done
fi
