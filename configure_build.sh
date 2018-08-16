# Find, load common utilities
# Defines IS_OSX, fetch_unpack
MULTIBUILD_DIR=$(dirname "${BASH_SOURCE[0]}")
source $MULTIBUILD_DIR/common_utils.sh

# Only source configure_build once
if [ -n "$CONFIGURE_BUILD_SOURCED" ]; then
    return
fi
CONFIGURE_BUILD_SOURCED=1

PLAT="${PLAT:x86_64}"
BUILD_PREFIX="${BUILD_PREFIX:-/usr/local}"

# Default compilation flags for OSX
# IS_OSX is defined in common_utils.sh
if [ -n "$IS_OSX" ]; then
    # Dual arch build by default
    ARCH_FLAGS=${ARCH_FLAGS:-"-arch i386 -arch x86_64"}
    # Only set CFLAGS, FFLAGS if they are not already defined.  Build functions
    # can override the arch flags by setting CFLAGS, FFLAGS
    export CFLAGS="${CFLAGS:-$ARCH_FLAGS}"
    export CXXFLAGS="${CXXFLAGS:-$ARCH_FLAGS}"
    export FFLAGS="${FFLAGS:-$ARCH_FLAGS}"

    # Disable homebrew auto-update
    export HOMEBREW_NO_AUTO_UPDATE=1
else
    # Strip all binaries after compilation.
    STRIP_FLAGS=${STRIP_FLAGS:-"-Wl,-strip-all"}

    export CFLAGS="${CFLAGS:-$STRIP_FLAGS}"
    export CXXFLAGS="${CXXFLAGS:-$STRIP_FLAGS}"
    export FFLAGS="${FFLAGS:-$STRIP_FLAGS}"
fi

# Promote BUILD_PREFIX on search path to any newly built libs
export CPPFLAGS="-I$BUILD_PREFIX/include $CPPFLAGS"
export LIBRARY_PATH="$BUILD_PREFIX/lib:$LIBRARY_PATH"
export PKG_CONFIG_PATH="$BUILD_PREFIX/lib/pkgconfig/:$PKG_CONFIG_PATH"
