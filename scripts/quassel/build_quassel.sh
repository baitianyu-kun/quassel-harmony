#!/bin/bash
set -e

# --- SDK Path ---
export NATIVE_OHOS_SDK="$TOOL_HOME/sdk/default/openharmony/native"

# --- Configuration ---
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." &> /dev/null && pwd )"

QUASSEL_SRC_DIR="$PROJECT_ROOT/third_party/quassel"
QUASSEL_BUILD_DIR="$PROJECT_ROOT/build/build-quassel-ohos"
QT_INSTALL_DIR="$PROJECT_ROOT/build/build-qt-ohos-install"
QT_HOST_INSTALL_DIR="$PROJECT_ROOT/build/build-qt-host-install"
ADDITIONAL_PKGS_DIR="$PROJECT_ROOT/additional-packages"
# Target Architecture (must match the one used for Qt)
export OHOS_TARGET_ARCH=${OHOS_TARGET_ARCH:-arm64-v8a}

# --- Validation ---
if [ -z "$NATIVE_OHOS_SDK" ]; then
    echo "Error: NATIVE_OHOS_SDK environment variable is not set."
    exit 1
fi

if [ ! -d "$QT_INSTALL_DIR" ]; then
    echo "Error: Qt installation not found at $QT_INSTALL_DIR."
    echo "Please run download_qt.sh and build_qt.sh first."
    exit 1
fi

# Add OHOS toolchain to PATH for compilation
export PATH="$NATIVE_OHOS_SDK/llvm/bin:$PATH"

# Set PKG_CONFIG_PATH
export PKG_CONFIG_PATH="$QT_INSTALL_DIR/lib/pkgconfig:$PKG_CONFIG_PATH"

# --- Preparation ---
echo "Creating build directory: $QUASSEL_BUILD_DIR"
mkdir -p "$QUASSEL_BUILD_DIR"

cd "$QUASSEL_BUILD_DIR"

# --- Build ---
echo "Running CMake for Quassel ($OHOS_TARGET_ARCH)..."
cmake "$QUASSEL_SRC_DIR" \
    -DCMAKE_TOOLCHAIN_FILE="$NATIVE_OHOS_SDK/build/cmake/ohos.toolchain.cmake" \
    -DOHOS_ARCH="$OHOS_TARGET_ARCH" \
    -DCMAKE_PREFIX_PATH="$QT_INSTALL_DIR;$ADDITIONAL_PKGS_DIR" \
    -DCMAKE_FIND_ROOT_PATH="$QT_INSTALL_DIR;$ADDITIONAL_PKGS_DIR" \
    -DQT_HOST_PATH="$QT_HOST_INSTALL_DIR" \
    -DQT_ADDITIONAL_HOST_PACKAGES_PREFIX_PATH="$QT_HOST_INSTALL_DIR" \
    -DQT_VERSION_MAJOR=6 \
    -DWANT_CORE=ON \
    -DWANT_QTCLIENT=ON \
    -DWANT_MONO=ON \
    -DWITH_KDE=OFF \
    -DWITH_WEBENGINE=OFF \
    -DWITH_LDAP=OFF \
    -DBUILD_TESTING=OFF

echo "Compiling Quassel..."
make -j$(nproc)

echo "Quassel build complete."
echo "The binary can be found in $QUASSEL_BUILD_DIR"
