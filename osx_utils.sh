#!/bin/bash
# Use with ``source osx_utils.sh``
set -e

# Get our own location on this filesystem, load common utils
MULTIBUILD_DIR=$(dirname "${BASH_SOURCE[0]}")
source $MULTIBUILD_DIR/common_utils.sh

MACPYTHON_URL=https://www.python.org/ftp/python
MACPYTHON_PY_PREFIX=/Library/Frameworks/Python.framework/Versions
GET_PIP_URL=https://bootstrap.pypa.io/get-pip.py
DOWNLOADS_SDIR=downloads
WORKING_SDIR=working

# As of 20 October 2018 - latest Python of each version with binary download
# available.
# See: https://www.python.org/downloads/mac-osx/
LATEST_2p7=2.7.15
LATEST_3p4=3.4.4
LATEST_3p5=3.5.4
LATEST_3p6=3.6.7
LATEST_3p7=3.7.1


function check_python {
    if [ -z "$PYTHON_EXE" ]; then
        echo "PYTHON_EXE variable not defined"
        exit 1
    fi
}

function check_pip {
    if [ -z "$PIP_CMD" ]; then
        echo "PIP_CMD variable not defined"
        exit 1
    fi
}

function check_var {
    if [ -z "$1" ]; then
        echo "required variable not defined"
        exit 1
    fi
}

function get_py_digit {
    check_python
    $PYTHON_EXE -c "import sys; print(sys.version_info[0])"
}

function get_py_mm {
    check_python
    $PYTHON_EXE -c "import sys; print('{0}.{1}'.format(*sys.version_info[0:2]))"
}

function get_py_mm_nodot {
    check_python
    $PYTHON_EXE -c "import sys; print('{0}{1}'.format(*sys.version_info[0:2]))"
}

function get_py_prefix {
    check_python
    $PYTHON_EXE -c "import sys; print(sys.prefix)"
}

function fill_pyver {
    # Convert major or major.minor format to major.minor.micro
    #
    # Hence:
    # 2 -> 2.7.11  (depending on LATEST_2p7 value)
    # 2.7 -> 2.7.11  (depending on LATEST_2p7 value)
    local ver=$1
    check_var $ver
    if [[ $ver =~ [0-9]+\.[0-9]+\.[0-9]+ ]]; then
        # Major.minor.micro format already
        echo $ver
    elif [ $ver == 2 ] || [ $ver == "2.7" ]; then
        echo $LATEST_2p7
    elif [ $ver == 3 ] || [ $ver == "3.7" ]; then
        echo $LATEST_3p7
    elif [ $ver == "3.6" ]; then
        echo $LATEST_3p6
    elif [ $ver == "3.5" ]; then
        echo $LATEST_3p5
    elif [ $ver == "3.4" ]; then
        echo $LATEST_3p4
    else
        echo "Can't fill version $ver" 1>&2
        exit 1
    fi
}

function pyinst_ext_for_version {
    # echo "pkg" or "dmg" depending on the passed Python version
    # Parameters
    #   $py_version (python version in major.minor.extra format)
    #
    # Earlier Python installers are .dmg, later are .pkg.
    local py_version=$1
    check_var $py_version
    py_version=$(fill_pyver $py_version)
    local py_0=${py_version:0:1}
    if [ $py_0 -eq 2 ]; then
        if [ "$(lex_ver $py_version)" -ge "$(lex_ver 2.7.9)" ]; then
            echo "pkg"
        else
            echo "dmg"
        fi
    elif [ $py_0 -ge 3 ]; then
        if [ "$(lex_ver $py_version)" -ge "$(lex_ver 3.4.2)" ]; then
            echo "pkg"
        else
            echo "dmg"
        fi
    fi
}

function pyinst_fname_for_version {
    # echo filename for OSX installer file given Python version
    # Parameters
    #   $py_version (python version in major.minor.extra format)
    local py_version=$1
    local inst_ext=$(pyinst_ext_for_version $py_version)
    local osx_ver=10.6
    echo "python-$py_version-macosx${osx_ver}.$inst_ext"
}

function install_macpython {
    # Install Python and set $PYTHON_EXE to the installed executable
    # Parameters:
    #     $version : [implementation-]major[.minor[.patch]]
    #         The Python implementation to install, e.g. "3.6" or "pypy-5.4"
    local version=$1
    if [[ "$version" =~ pypy-([0-9\.]+) ]]; then
        install_mac_pypy "${BASH_REMATCH[1]}"
    elif [[ "$version" =~ ([0-9\.]+) ]]; then
        install_mac_cpython "${BASH_REMATCH[1]}"
    else
        echo "config error: Issue parsing this implementation in install_python:"
        echo "    version=$version"
        exit 1
    fi
}

function install_mac_cpython {
    # Installs Python.org Python
    # Parameter $version
    # Version given in major or major.minor or major.minor.micro e.g
    # "3" or "3.4" or "3.4.1".
    # sets $PYTHON_EXE variable to python executable
    local py_version=$(fill_pyver $1)
    local py_stripped=$(strip_ver_suffix $py_version)
    local py_inst=$(pyinst_fname_for_version $py_version)
    local inst_path=$DOWNLOADS_SDIR/$py_inst
    mkdir -p $DOWNLOADS_SDIR
    curl $MACPYTHON_URL/$py_stripped/${py_inst} > $inst_path
    if [ "${py_inst: -3}" == "dmg" ]; then
        hdiutil attach $inst_path -mountpoint /Volumes/Python
        inst_path=/Volumes/Python/Python.mpkg
    fi
    sudo installer -pkg $inst_path -target /
    local py_mm=${py_version:0:3}
    PYTHON_EXE=$MACPYTHON_PY_PREFIX/$py_mm/bin/python$py_mm
    # Install certificates for Python 3.6
    local inst_cmd="/Applications/Python ${py_mm}/Install Certificates.command"
    if [ -e "$inst_cmd" ]; then
        sh "$inst_cmd"
    fi
}

function install_mac_pypy {
    # Installs pypy.org PyPy
    # Parameter $version
    # Version given in major or major.minor or major.minor.micro e.g
    # "3" or "3.4" or "3.4.1".
    # sets $PYTHON_EXE variable to python executable
    local py_version=$(fill_pypy_ver $1)
    local py_build=$(get_pypy_build_prefix $py_version)$py_version-osx64
    local py_zip=$py_build.tar.bz2
    local zip_path=$DOWNLOADS_SDIR/$py_zip
    mkdir -p $DOWNLOADS_SDIR
    wget -nv $PYPY_URL/${py_zip} -P $DOWNLOADS_SDIR
    untar $zip_path
    PYTHON_EXE=$(realpath $py_build/bin/pypy)
}

function install_pip {
    # Generic install pip
    # Gets needed version from version implied by $PYTHON_EXE
    # Installs pip into python given by $PYTHON_EXE
    # Assumes pip will be installed into same directory as $PYTHON_EXE
    check_python
    mkdir -p $DOWNLOADS_SDIR
    local py_mm=`get_py_mm`
    local get_pip_path=$DOWNLOADS_SDIR/get-pip.py
    curl $GET_PIP_URL > $get_pip_path
    # Travis VMS now install pip for system python by default - force install
    # even if installed already.
    sudo $PYTHON_EXE $get_pip_path --ignore-installed $pip_args
    PIP_CMD="sudo $(dirname $PYTHON_EXE)/pip$py_mm"
    # Append pip_args if present (avoiding trailing space cf using variable
    # above).
    if [ -n "$pip_args" ]; then
        PIP_CMD="$PIP_CMD $pip_args"
    fi
}

function install_virtualenv {
    # Generic install of virtualenv
    # Installs virtualenv into python given by $PYTHON_EXE
    # Assumes virtualenv will be installed into same directory as $PYTHON_EXE
    check_pip
    # Travis VMS install virtualenv for system python by default - force
    # install even if installed already
    $PIP_CMD install virtualenv --ignore-installed
    check_python
    VIRTUALENV_CMD="$(dirname $PYTHON_EXE)/virtualenv"
}

function make_workon_venv {
    # Make a virtualenv in given directory ('venv' default)
    # Set $PYTHON_EXE, $PIP_CMD to virtualenv versions
    # Parameter $venv_dir
    #    directory for virtualenv
    local venv_dir=$1
    if [ -z "$venv_dir" ]; then
        venv_dir="venv"
    fi
    venv_dir=`abspath $venv_dir`
    check_python
    $PYTHON_EXE -m virtualenv $venv_dir
    PYTHON_EXE=$venv_dir/bin/python
    PIP_CMD=$venv_dir/bin/pip
}

function remove_travis_ve_pip {
    # Remove travis installs of virtualenv and pip
    # FIXME: What if virtualenv is installed but pip is not?
    if [ "$(sudo which virtualenv)" == /usr/local/bin/virtualenv ] && [ "$(sudo which pip)" == /usr/local/bin/pip ]; then
        sudo pip uninstall -y virtualenv;
    fi
    if [ "$(sudo which pip)" == /usr/local/bin/pip ]; then
        sudo pip uninstall -y pip;
    fi
}

function set_py_vars {
    # Used by terryfy project; left here for back-compatibility
    export PATH="`dirname $PYTHON_EXE`:$PATH"
    export PYTHON_EXE PIP_CMD
}

function get_macpython_environment {
    # Set up MacPython environment
    # Parameters:
    #     $version : [implementation-]major[.minor[.patch]]
    #         The Python implementation to install, e.g. "3.6" or "pypy-5.4"
    #     $venv_dir : {directory_name|not defined}
    #         If defined - make virtualenv in this directory, set python / pip
    #         commands accordingly
    #
    # Installs Python
    # Sets $PYTHON_EXE to path to Python executable
    # Sets $PIP_CMD to full command for pip (including sudo if necessary)
    # If $venv_dir defined, Sets $VIRTUALENV_CMD to virtualenv executable
    # Puts directory of $PYTHON_EXE on $PATH
    local version=$1
    local venv_dir=$2


    if [ "$USE_CCACHE" == "1" ]; then
        activate_ccache
    fi
    
    remove_travis_ve_pip
    install_macpython $version
    install_pip

    if [ -n "$venv_dir" ]; then
        install_virtualenv
        make_workon_venv $venv_dir
        source $venv_dir/bin/activate
    else
        export PATH="`dirname $PYTHON_EXE`:$PATH"
    fi
    export PYTHON_EXE PIP_CMD
}

function install_delocate {
    check_pip
    $PIP_CMD install delocate
}

function repair_wheelhouse {
    local wheelhouse=$1

    install_delocate
    delocate-wheel $wheelhouse/*.whl # copies library dependencies into wheel
    # Add platform tags to label wheels as compatible with OSX 10.9 and
    # 10.10.  The wheels will be built against Python.org Python, and so will
    # in fact be compatible with OSX >= 10.6.  pip < 6.0 doesn't realize
    # this, so, in case users have older pip, add platform tags to specify
    # compatibility with later OSX.  Not necessary for OSX released well
    # after pip 6.0.  See:
    # https://github.com/MacPython/wiki/wiki/Spinning-wheels#question-will-pip-give-me-a-broken-wheel
    delocate-addplat --rm-orig -x 10_9 -x 10_10 $wheelhouse/*.whl
}

function install_pkg_config {
    # Install pkg-config avoiding error from homebrew
    # See :
    # https://github.com/matthew-brett/multibuild/issues/24#issue-221951587
    command -v pkg-config > /dev/null 2>&1 || brew install pkg-config
}

function activate_ccache {

    brew install ccache
    export PATH=/usr/local/opt/ccache/libexec:$PATH
    export CCACHE_CPP2=1

    # Prove to the developer that ccache is activated
    echo "Using C compiler: $(which clang)"
}
