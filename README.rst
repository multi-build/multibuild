################################################
Utilities for building on Travis CI and AppVeyor
################################################

*****************************
Update: Uploads and Rackspace
*****************************

The original Multibuild default was to upload wheels to a Rackspace container,
where Rackspace kindly donated the hosting to the Scikit-learn team.  We had
a URL pointing to the Rackspace container: `http://wheels.scipy.org`.

Rackspace finally stopped subsidizing this container, and the Rackspace of
`http://wheels.scipy.org` is no more. Projects using Multibuild have moved to
using https://anaconda.org/scipy-wheels-nightly/ for weekly uploads and
https://anaconda.org/multibuild-wheels-staging for staging wheels to PyPI.

Another option is to use GitHub for staging --- as do Cython `for Travis CI
<https://github.com/MacPython/cython-wheels/blob/master/.travis.yml#L144>`_
and `for AppVeyor
<https://github.com/MacPython/cython-wheels/blob/master/appveyor.yml#L118>`_.
Here is the NumPy code (for running on Travis CI) to upload to Anaconda:
https://github.com/MacPython/numpy-wheels/blob/master/.travis.yml#L99

For projects housed under the MacPython GitHub organization, you have access to
Anaconda upload tokens via the "Organization Secrets"
https://github.com/MacPython/numexpr-wheels/settings/secrets . You can use
these to move to GitHub Actions (they provide x86 machines for Windows, Linux
and Mac). Otherwise we (please raise an issue here) will need to negotiate
getting you tokens.

************
Introduction
************

A set of scripts to automate builds of macOS and Manylinux1 wheels on the
`Travis CI <https://travis-ci.org/>`_ infrastructure, and also Windows
wheels on the `AppVeyor <https://ci.appveyor.com/>`_ infrastructure.

The Travis CI scripts are designed to build *and test*:

* 64-bit macOS wheels built for macOS 10.9+
* 64/32-bit macOS wheels built for macOS 10.6+
* 64-bit ``manylinuxX_x86_64`` wheels, both narrow and wide Unicode builds,
  where `X` is any valid Manylinux version: `1`, `2010`, `2014` or `_2_24`.
* 32-bit ``manylinuxX_i686`` wheels, both narrow and wide Unicode builds

You can currently build and test against Pythons 2.7, 3.5, 3.6, 3.7, 3.8 and 3.9

The small innovation here is that you can test against Linux 32-bit builds, both
wide and narrow Unicode Python 2 builds, which was not easy on the default
Travis CI configurations.

The AppVeyor setup is designed to build *and test*:

* 64-bit Windows ``win_amd64`` wheels
* 32-bit Windows ``win32`` wheels

You can currently build and test against Pythons 2.7, 3.5, 3.6, 3.7, 3.8, 3.9

*****************
How does it work?
*****************

Multibuild is a series of bash scripts that define bash functions to build and
test wheels.

Configuration is by overriding the default build function, and defining a test
function.

The bash scripts are layered, in the sense that they are composed of a number of scripts
which are sourced in sequence, each one potentially overriding previous ones.

macOS
=====

The following bash scripts are sourced in this order::

    multibuild/common_utils.sh
    multibuild/osx_utils.sh
    env_vars.sh
    multibuild/configure_build.sh
    multibuild/library_builders.sh
    config.sh

See ``multibuild/travis_osx_steps.sh``

The macOS build / test phases run on the macOS VM started by Travis CI.
Therefore any environment variable defined in ``.travis.yml`` or the bash
shell scripts listed above are available for your build and test.

Build options are controlled mainly by the following environment
variables:

* ``MB_PYTHON_VER`` sets the Python version targetted: ``major.minor.patch``
  for CPython, or ``pypy-major.minor`` for PyPy.
* ``MB_PYTHON_OSX_VER`` sets the minimum macOS SDK version for any C
  extensions. For CPython targets it may be set to 10.6 or 10.9, provided a
  corresponding Python build is available at `python.org
  <https://www.python.org/downloads/mac-osx/>`_. It defaults to the highest
  version available. It's ignored for PyPy targets.
* ``PLAT`` sets the architectures built for any C extensions: ``x86_64`` or
  ``intel`` for 64-bit or 64/32-bit respectively. It defaults to the same
  arches as the target Python version: 64-bit for CPython macOS 10.9 or PyPy,
  and 64/32-bit for CPython 10.6.

In most cases it's best to rely on the defaults for ``MB_PYTHON_OSX_VER`` and
``PLAT``, rather than setting them explicitly. Examples of exceptions to this
guideline include:

* setting ``MB_PYTHON_OSX_VER=10.6`` to build a 10.6 64/32-bit CPython wheel
  for Python 2.7 (default for 2.7 is 10.9 64-bit)
* setting ``MB_PYTHON_OSX_VER=10.6 and PLAT=x86_64`` to build a 10.6 64-bit
  only wheel (10.6 would normally be 64/32-bit). Such a wheel would still have
  a platform tag of ``macosx_10_6_intel`` , advertising support for both 64 and
  32-bit, but wouldn't work in 32-bit mode. This may be OK given how unlikely it
  is that there is still anyone actually running Python on macOS in 32-bit
  mode.

The ``build_wheel`` function builds the wheel, and ``install_run``
function installs and tests it.  Look in ``multibuild/common_utils.sh`` for
default definitions of these functions.  See below for more details, many of
which are common to macOS and Linux.

Manylinux
=========

The build phase is in a Manylinux Docker container, but the test phase is in
a clean container.


Build phase
-----------

Specify the Manylinux version to build for with the ``MB_ML_VER`` environment
variable. The default version is ``1``.  Versions that are currently valid are:

* ``1`` corresponding to manylinux1 (see `PEP 513 <https://www.python.org/dev/peps/pep-0513>`_).
* ``2010``  corresponding to manylinux2010 (see `PEP 571 <https://www.python.org/dev/peps/pep-0571>`_).
* ``2014`` corresponding to manylinux2014 and adds more architectures to ``PLAT``
  (see `PEP 599 <https://www.python.org/dev/peps/pep-0599>`_).
* ``_2_24`` corresponding to manylinux_2_24 (see `PEP 600 <https://www.python.org/dev/peps/pep-0600>`_).

The environment variable specified which Manylinux docker container you are building in.

The ``PLAT`` environment variable can be one of

* ``x86_64``, for 64-bit x86
* ``i686``, for 32-bit x86
* ``s390x``, for 64-bit s390x
* ``ppc64le``, for PowerPC
* ``aarch64``, for ARM
* ``arm64``, for Apple silicon
* ``universal2``, for both Apple silicon and 64-bit x86

The default is ``x86_64``. Only ``x86_64`` and ``i686`` are valid on manylinux1 and manylinux2010.

``multibuild/travis_linux_steps.sh`` defines the ``build_wheel`` function,
which starts up the Manylinux1 Docker container to run a wrapper script
``multibuild/docker_build_wrap.sh``, that (within the container) sources the
following bash scripts::

    multibuild/common_utils.sh
    multibuild/manylinux_utils.sh
    env_vars.sh
    multibuild/configure_build.sh
    multibuild/library_builders.sh
    config.sh

See ``docker_build_wrap.sh`` to review the order of script sourcing.

See the definition of ``build_multilinux`` in
``multibuild/travis_linux_steps.sh`` for the environment variables passed from
Travis CI to the Manylinux1 container.

Once in the container, after sourcing the scripts above, the wrapper runs the
real ``build_wheel`` function, which now comes (by default) from
``multibuild/common_utils.sh``.

Test phase
----------

Specify the version to test with the ``DOCKER_TEST_IMAGE`` environment
variable. The default version is dependent on ``PLAT``:

* ``matthewbrett/trusty:64``, for ``x86_64``
* ``matthewbrett/trusty:32`` for ``i686``
* ``multibuild/xenial_arm64v8`` for ``aarch64``
* ``multibuild/xenial_ppc64le`` for ``ppc64le``
* ``mutlibuild/xenial_s390x`` for ``s390x``

Other valid values are any in https://hub.docker.com/orgs/multibuild/repositories,
using the correct platform code. Alternatively, you can use the substitution
pattern ``multibuild/xenial_{PLAT}`` in the ``.travis.yml`` file.

See ``multibuild/docker_test_wrap.sh``.

``multibuild/travis_linux_steps.sh`` defines the ``install_run`` function,
which starts up the testing Docker container with the wrapper script
``multibuild/docker_test_wrap.sh``. The wrapper script sources the following
bash scripts::

    multibuild/common_utils.sh
    config.sh

See ``docker_test_wrap.sh`` for script source order.

See ``install_run`` in ``multibuild/travis_linux_steps.sh`` for the
environment variables passed into the container.

It then (in the container) runs the real ``install_run`` command, which comes
(by default) from ``multibuild/common_utils.sh``.

*********************************
Standard build and test functions
*********************************

The standard build command is ``build_wheel``.  This is a bash function.  By
default the function that is run on macOS, and in the Manylinux container for
the build phase, is defined in ``multibuild/common_utils.sh``.  You can
override the default function in the project ``config.sh`` file (see below).

If you are building a wheel from PyPI, rather than from a source repository,
you can use the ``build_index_wheel`` command, again defined in
``multibuild/common_utils.sh``.

Typically, you can get away with leaving the default ``build_wheel`` /
``build_index_wheel`` functions to do their thing, but you may need to define
a ``pre_build`` function in ``config.sh``.  The default ``build_wheel`` and
``build_index_wheel`` functions will call the ``pre_build`` function, if
defined, before building the wheel, so ``pre_build`` is a good place to build
any required libraries.

The standard test command is the bash function ``install_run``.  The version
run on macOS and in the Linux testing container is also defined in
``multibuild/common_utils.sh``.  Typically, you do not override this function,
but you in that case you will need to define a ``run_tests`` function, to run
your tests, returning a non-zero error code for failure.  The default
``install_run`` implementation calls the ``run_tests`` function, which you
will likely define in ``config.sh``.  See the examples below for examples of
less and more complicated builds, where the complicated builds override more
of the default implementations.

********************
To use these scripts
********************

* Make a repository for building wheels on Travis CI - e.g.
  https://github.com/MacPython/astropy-wheels - or in your case maybe
  ``https://github.com/your-org/your-project-wheels``;

* Add this (here) repository as a submodule::

    git submodule add https://github.com/matthew-brett/multibuild.git

* Add your own project repository as another submodule::

    git submodule add https://github.com/your-org/your-project.git

* Create a ``.travis.yml`` file, something like this::

    env:
        global:
            - REPO_DIR=your-project
            # Commit from your-project that you want to build
            - BUILD_COMMIT=v0.1.0
            # pip dependencies to _build_ your project
            - BUILD_DEPENDS="cython numpy"
            # pip dependencies to _test_ your project.  Include any dependencies
            # that you need, that are also specified in BUILD_DEPENDS, this will be
            # a separate install.
            # Now see the Uploads section for the stuff you need to
            # upload your wheels after CI has built them.

    # You will likely prefer "language: generic" for travis configuration,
    # rather than, say "language: python". Multibuild doesn't use
    # Travis-provided Python but rather installs and uses its own, where the
    # Python version is set from the MB_PYTHON_VERSION variable. You can still
    # specify a language here if you need it for some unrelated logic and you
    # can't use Multibuild-provided Python or other software present on a
    # builder.
    language: generic

    # For CPython macOS builds only, the minimum supported macOS version and
    # architectures of any C extensions in the wheel are set with the variable
    # MB_PYTHON_OSX_VER: 10.9 (64-bit only) or 10.6 (64/32-bit dual arch). By
    # default this is set to the highest available for the Python version selected
    # using MB_PYTHON_VERSION. You should only need to set this explicitly if you
    # are building a 10.6 dual-arch build for a CPython version where both a 10.9 and
    # 10.6 build are available (for example, 2.7 or 3.7).
    # All PyPy macOS builds are 64-bit only.

    # Required in Linux to invoke `docker` ourselves
    services: docker

    # Host distribution.  This is the distribution from which we run the build
    # and test containers, via docker.
    dist: xenial

    # osx image that enables building Apple silicon libraries
    osx_image: xcode12.2

    matrix:
      include:
        - os: linux
          env: MB_PYTHON_VERSION=2.7
        - os: linux
          env:
            - MB_PYTHON_VERSION=2.7
            - UNICODE_WIDTH=16
        - os: linux
          env:
            - MB_PYTHON_VERSION=2.7
            - PLAT=i686
        - os: linux
          env:
            - MB_PYTHON_VERSION=2.7
            - PLAT=i686
            - UNICODE_WIDTH=16
        - os: linux
          env:
            - MB_PYTHON_VERSION=3.5
        - os: linux
          env:
            - MB_PYTHON_VERSION=3.5
            - PLAT=i686
        - os: linux
          env:
            - MB_PYTHON_VERSION=3.6
        - os: linux
          env:
            - MB_PYTHON_VERSION=3.6
            - PLAT=i686
        - os: osx
          env:
            - MB_PYTHON_VERSION=2.7
            - MB_PYTHON_OSX_VER=10.6
        - os: osx
          env:
            - MB_PYTHON_VERSION=2.7
        - os: osx
          env:
            - MB_PYTHON_VERSION=3.5
        - os: osx
          env:
            - MB_PYTHON_VERSION=3.6
        - os: osx
          env:
            - MB_PYTHON_VERSION=3.7
            - MB_PYTHON_OSX_VER=10.6
        - os: osx
          env:
            - MB_PYTHON_VERSION=3.7
        - os: osx
          env:
            - MB_PYTHON_VERSION=3.8
        - os: osx
          env:
            - MB_PYTHON_VERSION=3.9
            - PLAT="universal2"
        - os: osx
          env:
            - MB_PYTHON_VERSION=3.9
        - os: osx
          language: generic
          env:
            - MB_PYTHON_VERSION=pypy-5.7

    before_install:
        - source multibuild/common_utils.sh
        - source multibuild/travis_steps.sh
        - before_install

    install:
        # Maybe get and clean and patch source
        - clean_code $REPO_DIR $BUILD_COMMIT
        - build_wheel $REPO_DIR $PLAT

    script:
        - install_run $PLAT

    after_success:
        # Here you should put the code to upload your wheels
        # See the Uploads section for more details.

  The example above is for a project building from a Git submodule.  If you
  aren't building from a submodule, but want to use ``pip`` to build from a
  source archive on https://pypi.org or similar, replace the first few lines
  of the ``.travis.yml`` file with something like::

    env:
        global:
            # Instead of REPO_DIR, BUILD_COMMIT
            - PROJECT_SPEC="tornado==4.1.1"

  then your ``install`` section could look something like this::

    install:
        - build_index_wheel $PROJECT_SPEC


* Next create a ``config.sh`` for your project, that fills in any steps you
  need to do before building the wheel (such as building required libraries).
  You also need this file to specify how to run your tests::

    # Define custom utilities
    # Test for macOS with [ -n "$IS_MACOS" ]

    function pre_build {
        # Any stuff that you need to do before you start building the wheels
        # Runs in the root directory of this repository.
        :
    }

    function run_tests {
        # Runs tests on installed distribution from an empty directory
        python --version
        python -c 'import sys; import yourpackage; sys.exit(yourpackage.test())'
    }

  Optionally you can specify a different location for ``config.sh`` file with
  the ``$CONFIG_PATH`` environment variable.

* Optionally, create an ``env_vars.sh`` file to override the defaults for any
  environment variables used by
  ``configure_build.sh``/``library_builders.sh``. In Linux, the environment
  variables used for the build cannot be set in the ``.travis.yml`` file,
  because the build processing runs in a Docker container, so the only
  environment variables that reach the container are those passed in via the
  ``docker run`` command, or those set in ``env_vars.sh``.

  As for the ``config.sh`` file, you can specify a different location for the
  file by setting the ``$ENV_VARS_PATH`` environment variable.  The path in
  ``$ENV_VARS_PATH`` is relative to the repository root directory.  For
  example, if your repository had a subdirectory ``scripts`` with a file
  ``my_env_vars.sh``, you should set ``ENV_VARS_PATH=scripts/my_env_vars.sh``.

* Make sure your project is set up to build on Travis CI, and you should now
  be ready (to begin the long slow debugging process, probably).

* For the Windows wheels, create an ``appveyor.yml`` file, something like:

  - https://github.com/MacPython/astropy-wheels/blob/master/appveyor.yml
  - https://github.com/MacPython/nipy-wheels/blob/master/appveyor.yml
  - https://github.com/MacPython/pytables-wheels/blob/master/appveyor.yml

  Note the Windows test customizations etc are inside ``appveyor.yml``,
  and that ``config.sh`` and ``env_vars.sh`` are only for the
  Linux/Mac builds on Travis CI.

* Make sure your project is set up to build on AppVeyor, and you should now
  be ready (for what could be another round of slow debugging).

* For Apple silicon support you can either create an ``arm64`` wheel or
  a ``universal2`` wheel by supplying ``PLAT`` env variable.
  ``universal2`` builds work on both ``arm64`` and ``x86_64`` platforms
  and also make it possible for the wheel code to work when switching the
  architecture on Apple silicon machines where ``x86_64`` can be run
  using Rosetta2 emulation.

  There are two ways to build ``universal2`` builds.

  1. Build with ``-arch x86_64 -arch arm64``.
     These flags instruct the C/C++ compiler to compile twice and create a
     fat object/executable/library. This is the easiest, but has several
     drawbacks. If you are using C/C++ libraries that are built using
     library_builders, it's highly likely that they don't build correctly
     because most build systems and packages don't support building fat binaries.
     We could possibly build them separately and fuse them, but the headers might
     not be identical which is required when building the wheel as a ``universal2``
     wheel. If you are using Fortran, ``gfortran`` doesn't support fat binaries.

  2. Build ``arm64`` and ``x86_64`` wheels separately and fuse them.
     For this to work, we need to build the C/C++ libraries twice. Therefore,
     the library building is once called with ``BUILD_PREFIX=${BUILD_PREFIX:-/usr/local}``
     for ``x86_64`` and then called again with ``BUILD_PREFIX=/opt/arm64-builds``.
     Once the two wheels are created, these two are merged. Both the
     ``arm64`` and ``universal2`` wheels are outputs for this build.

  In multibuild we are going with option 2. You can override this behaviour by
  overriding the function ``wrap_wheel_builder``.
  To build Apple silicon builds, you should use a CI service with Xcode 12 with
  universal build support and make sure that xcode is the default.

If your project depends on NumPy, you will want to build against the earliest
NumPy that your project supports - see `forward, backward NumPy compatibility
<https://stackoverflow.com/questions/17709641/valueerror-numpy-dtype-has-the-wrong-size-try-recompiling/18369312#18369312>`_.
See the `astropy-wheels Travis file
<https://github.com/MacPython/astropy-wheels/blob/master/.travis.yml>`_ for an
example specifying NumPy build and test dependencies.

Here are some simple example projects:

* https://github.com/MacPython/astropy-wheels
* https://github.com/scikit-image/scikit-image-wheels
* https://github.com/MacPython/nipy-wheels
* https://github.com/MacPython/dipy-wheels

Less simple projects where there are some serious build dependencies, and / or
macOS / Linux differences:

* https://github.com/MacPython/matplotlib-wheels
* https://github.com/python-pillow/Pillow-wheels
* https://github.com/MacPython/h5py-wheels

**********************
Multibuild development
**********************

The main multibuild repository is always at
https://github.com/matthew-brett/multibuild

We try to keep the ``master`` branch stable and do testing and development
in the ``devel`` branch.  From time to time we merge ``devel`` into ``master``.

In practice, you can check out the newest commit from ``devel`` that works
for you, then stay at it until you need newer features.
