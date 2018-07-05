# Procedure for new Pyton release

* Check Manylinux updated with new release;
* Update latest Python versions to osx_utils version checker, and add tests -
  see commits starting with f8b6cc7.
* Add .travis.yml matrix entry for new Python.
* Add new Python builds to https://github.com/matthew-brett/trusty, for
  testing.
* Update Cython builds for new version.
* Update Numpy build.
* Upload Numpies back to required build versions for Scipy, Matplotlib.
* Update Scipy
* Kiwisolver wheels
* Matplotlib wheels
* Update everything else.

## General procedure

Check BUILD_COMMIT.
Update multibuild submodule.
Check dependencies can be installed.
