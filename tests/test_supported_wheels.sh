# Test supported wheels script
PYTHON_EXE=${PYTHON_EXE:-python}
if [ -z "$PIP_CMD" ]; then
    pip_install="pip install --user"
else
    pip_install="$PIP_CMD install"
fi
# Current wheel versions not available for older Pythons.
lpv=$(lex_ver $MB_PYTHON_VERSION)
# Check no errors.
if [ $lpv -ge $(lex_ver 3.5) ] || [ $lpv -lt $(lex_ver 3) ]; then
    for whl in wheel==0.31.1 wheel==0.32.0 wheel; do
        $pip_install -U $whl
        $PYTHON_EXE supported_wheels.py \
        tornado-5.1-cp27-cp27m-macosx_10_6_intel.whl \
        tornado-5.1-cp27-cp27m-macosx_10_9_intel.whl \
        tornado-5.1-cp27-cp27m-macosx_10_9_x86_64.whl \
        tornado-5.1-cp27-cp27m-macosx_10_13_x86_64.whl \
        tornado-5.1-cp36-cp36m-macosx_10_6_intel.whl \
        tornado-5.1-cp36-cp36m-macosx_10_9_intel.whl \
        tornado-5.1-cp36-cp36m-macosx_10_9_x86_64.whl \
        tornado-5.1-cp36-cp36m-macosx_10_13_x86_64.whl \
        texext-0.6.1-cp36-none-any.whl
    done
fi

# Test that wheels for versions other than our own, not supported.
if [ $(uname) == 'Darwin' ]; then
    # 2>&1 because Python 2.7 version goes to stderr
    our_ver=$(python --version 2>&1 | awk '{print $2}' | awk -F '.' '{print $1$2}')
    other_ver=$([ "$our_ver" == "37" ] && echo "38" || echo "37")
    good_whl="tornado-5.1-cp${our_ver}-cp${our_ver}m-macosx_10_9_x86_64.whl"
    bad_whl="tornado-5.1-cp${other_ver}-cp${other_ver}m-macosx_10_9_x86_64.whl"
    if [ "$($PYTHON_EXE supported_wheels.py $bad_whl)" != "" ]; then
        echo "$bad_whl not supported, but supported wheels says it is."
        RET=1
    fi
    if [ "$($PYTHON_EXE supported_wheels.py $good_whl)" != "$good_whl" ]; then
        echo "$good_whl supported, but supported wheels says it is not."
        RET=1
    fi
    good_whl2="mypkg-0.3-cp${our_ver}-cp${our_ver}m-macosx_10_9_x86_64.whl"
    both="$good_whl
$good_whl2"
    if [ "$($PYTHON_EXE supported_wheels.py $good_whl $good_whl2)" != "$both" ]; then
        echo "$good_whl, $good_whl2 supported, supported_wheels does not return both."
        RET=1
    fi
    if [ "$($PYTHON_EXE supported_wheels.py $good_whl $bad_whl $good_whl2)" != "$both" ]; then
        echo "$good_whl, $good_whl2 supported, $bad_whl not; supported_wheels disagrees."
        RET=1
    fi
fi

