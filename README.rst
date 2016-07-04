######################################################
Utilities for building on travis-ci with OSX and Linux
######################################################

A set of scripts to automate builds of OSX and manylinux1 wheels on travis-ci
infrastructure.

These scripts are designed to build *and test*:

* Dual architecture OSX wheels;
* 64-bit manylinux1_x86_64 wheels, both narrow and wide unicode builds;
* 32-bit manylinux1_i686 wheels, both narrow and wide unicode builds.

You can currently build and test against Pythons 2.6, 2.7, 3.3, 3.4, 3.5.

The small innovation here is that you can test against 32-bit builds, and both
wide and narrow unicode Python 2 builds, which was not easy on the default
travis-ci configurations.

*****************
How does it work?
*****************

Multibuild is a series of bash scripts that define bash functions to build and
test wheels.

Configuration is by overriding the default build function, and defining a test
function.

The bash scripts are layered, in the sense that they loaded in the following
sequence:

* OSX - build and test phases.  See ``multibuild/travis_osx_steps.sh``.

  * multibuild/common_utils.sh
  * multibuild/osx_utils.sh
  * multibuild/library_builders.sh
  * multibuild/travis_osx_steps.sh
  * config.sh

* Manylinux:

  * build phase (in manylinux docker container). See
    ``multibuild/docker_build_wrap.sh``:

    * multibuild/common_utils.sh
    * multibuild/manylinux_utils.sh
    * multibuild/library_builders.sh
    * config.sh

  * test phase (in Ubuntu 14.04 docker container).  See
    ``multibuild/docker_test_wrap.sh``:

    * multibuild/common_utils.sh
    * config.sh

*********************
Environment variables
*********************

The OSX build / test is the more straightforward of the two, because the build
and test phase are on the same VM.  Therefore any environment variable defined
in the ``.travis.yml`` or bash shell scripts listed above are available for
your build and test.

The manylinux1 build / test is more complicated, because the build has to run
inside a manylinux docker container, and the test has to run in another Ubuntu
container.  See ``multibuild/travis_linux_steps.sh`` for the default
invocation of docker for the build and test phases, and the environment
variables available inside the containers.

*********************************
Standard build and test functions
*********************************

The standard build commmand is ``build_wheel``.  This is a bash function.  By
default it is defined in ``multibuild/common_utils.sh``, but you can override
it in the project ``config.sh`` file (see below).

The standard test command is the bash function ``install_run``.  This is also
defined ``multibuild/common_utils.sh``.  Typically, you do not override this
function, but you define a ``pre_build`` function in ``config.sh``, to build
any libraries you need, and a ``run_tests`` function, to run your tests,
returning a non-zero error code for failure.  The default ``install_run``
implementation will call ``pre_build``, if defined, and then calls the
``run_tests`` function, which you must define, probably in ``config.sh``.  See
the examples below for examples of less and more complicateb builds, where the
complicated builds override more of the default implementations.

********************
To use these scripts
********************

* Make a repository for building wheels on travis-ci - e.g.
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
        - BUILD_DEPENDS="Cython numpy"
        # pip dependencies to _test_ your project.  Include any dependencies
        # that you need, that are also specified in BUILD_DEPENDS, this will be
        # a separate install.
        - TEST_DEPENDS="numpy scipy pytest"
        - PLAT=x86_64
        - UNICODE_WIDTH=32
        - WHEELHOUSE_UPLOADER_USERNAME=travis-worker
        # Following generated with
        # travis encrypt -r your-org/your-project-wheels WHEELHOUSE_UPLOADER_SECRET=<the api key>
        # This is for Rackspace uploads.  Contact the scikit-learn team for
        # permission (and the API key) to upload to the Rackspace account used
        # here, or use your own account.
        - secure:
            "MNKyBWOzu7JAUmC0Y+JhPKfytXxY/ADRmUIMEWZV977FLZPgYctqd+lqel2QIFgdHDO1CIdTSymOOFZckM9ICUXg9Ta+8oBjSvAVWO1ahDcToRM2DLq66fKg+NKimd2OfK7x597h/QmUSl4k8XyvyyXgl5jOiLg/EJxNE2r83IA="

    language: python
    # The travis Python version is unrelated to the version we build and test
    # with.  This is set with the MB_PYTHON_VERSION variable.
    python: 3.5
    sudo: required
    dist: trusty
    services: docker

    exclude:
      # Exclude the default Python 3.5 build
      - python: 3.5
    include:
      - os: linux
        env:
          - MB_PYTHON_VERSION=2.6
      - os: linux
        env:
          - MB_PYTHON_VERSION=2.6
          - PLAT=i686
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
          - MB_PYTHON_VERSION=3.3
      - os: linux
        env:
          - MB_PYTHON_VERSION=3.3
          - PLAT=i686
      - os: linux
        env:
          - MB_PYTHON_VERSION=3.4
      - os: linux
        env:
          - MB_PYTHON_VERSION=3.4
          - PLAT=i686
      - os: linux
        env:
          - MB_PYTHON_VERSION=3.5
      - os: linux
        env:
          - MB_PYTHON_VERSION=3.5
          - PLAT=i686
      - os: osx
        language: objective-c
        env:
          - MB_PYTHON_VERSION=2.7
      - os: osx
        language: objective-c
        env:
          - MB_PYTHON_VERSION=3.4
      - os: osx
        language: objective-c
        env:
          - MB_PYTHON_VERSION=3.5

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
        # Upload wheels to Rackspace container
        - pip install wheelhouse-uploader
        # This uploads the wheels to a Rackspace container owned by the
        # scikit-learn team, available at http://wheels.scipy.org.  See above
        # for information on using this account or choosing another.
        - python -m wheelhouse_uploader upload --local-folder
            ${TRAVIS_BUILD_DIR}/wheelhouse/
            --no-update-index
            wheels

* Next create a ``config.sh`` for your project, that fills in any steps you
  need to do before building the wheel (such as building required libraries).
  You also need this file to specify how to run your tests::

    # Define custom utilities
    # Test for OSX with [ -n "$IS_OSX" ]

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

* Make sure your project is set up to build on travis-ci, and you should now
  be ready (to begin the long slow debugging process, probably).

If your project depends on numpy, you will want to build against the earliest
numpy that your project supports - see `forward, backward numpy compatibility
<http://stackoverflow.com/questions/17709641/valueerror-numpy-dtype-has-the-wrong-size-try-recompiling/18369312#18369312>`_.
See the `astropy-wheels travis file
<https://github.com/MacPython/astropy-wheels/blob/master/.travis.yml>`_ for an
example specifying numpy build and test dependencies.

Here are some simple example projects:

* https://github.com/MacPython/astropy-wheels
* https://github.com/scikit-image/scikit-image-wheels
* https://github.com/MacPython/nipy-wheels
* https://github.com/MacPython/dipy-wheels

Less simple projects where there are some serious build dependencies, and / or
OSX / Linux differences:

* https://github.com/MacPython/matplotlib-wheels
* https://github.com/python-pillow/Pillow-wheels
* https://github.com/MacPython/h5py-wheels
