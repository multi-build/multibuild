# Test supported wheels script
PYTHON_EXE=${PYTHON_EXE:-python}
if [ -z "$PIP_CMD" ]; then
    pip_install="$PYTHON_EXE -m pip install"
else
    pip_install="$PIP_CMD install"
fi
# Needed for supported_wheels script
$pip_install packaging
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
py_impl=$($PYTHON_EXE -c 'import platform; print(platform.python_implementation())')
if [ "$py_impl" == 'CPython' ] && [ $(uname) == 'Darwin' ]; then
    our_ver=$($PYTHON_EXE -c 'import sys; print("{}{}".format(*sys.version_info[:2]))')
    other_ver=$([ "$our_ver" == "37" ] && echo "36" || echo "37")
    # Python <= 3.7 needs m for API tag.
    api_m=$([ $our_ver -le 37 ] && echo "m") || :
    whl_suff="cp${our_ver}-cp${our_ver}${api_m}-macosx_10_9_x86_64.whl"
    good_whl="tornado-5.1-${whl_suff}"
    bad_whl="tornado-5.1-cp${other_ver}-cp${other_ver}m-macosx_10_9_x86_64.whl"
    if [ "$($PYTHON_EXE supported_wheels.py $bad_whl)" != "" ]; then
        echo "$bad_whl not supported, but supported wheels says it is."
        RET=1
    fi
    if [ "$($PYTHON_EXE supported_wheels.py $good_whl)" != "$good_whl" ]; then
        echo "$good_whl supported, but supported wheels says it is not."
        RET=1
    fi
    good_whl2="mypkg-0.3-${whl_suff}"
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

