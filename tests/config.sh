set -ex
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

function run_tests {
    $PYTHON_EXE -c "import simplejson"
}

