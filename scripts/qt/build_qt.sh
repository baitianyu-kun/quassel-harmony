#!/bin/bash
set -e

# --- SDK Path ---
export OHOS_SDK="$TOOL_HOME/sdk/default/openharmony"

# --- Configuration ---
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." &> /dev/null && pwd )"

# Source directories
QT_SRC_DIR="$PROJECT_ROOT/build/src/qtbase"
QTTOOLS_SRC_DIR="$PROJECT_ROOT/build/src/qttools"
QTSVG_SRC_DIR="$PROJECT_ROOT/build/src/qtsvg"
QTDECLARATIVE_SRC_DIR="$PROJECT_ROOT/build/src/qtdeclarative"
QT5COMPAT_SRC_DIR="$PROJECT_ROOT/build/src/qt5compat"

# Build directories
QT_BUILD_DIR="$PROJECT_ROOT/build/build-qt-ohos"
QTTOOLS_BUILD_DIR="$PROJECT_ROOT/build/build-qttools-ohos"
QTSVG_BUILD_DIR="$PROJECT_ROOT/build/build-qtsvg-ohos"
QTDECLARATIVE_BUILD_DIR="$PROJECT_ROOT/build/build-qtdeclarative-ohos"
QT5COMPAT_BUILD_DIR="$PROJECT_ROOT/build/build-qt5compat-ohos"

# Host path and Install directory
QT_HOST_PATH="$PROJECT_ROOT/build/build-qt-host"
QT_ALL_INSTALL_DIR="$PROJECT_ROOT/build/build-qt-ohos-install"

# Additional packages path
export OHOS_ADDITIONAL_PACKAGES="$PROJECT_ROOT/additional-packages"

# Target Architecture
export OHOS_TARGET_ARCH=${OHOS_TARGET_ARCH:-arm64-v8a}
export PARALLEL_JOBS=${PARALLEL_JOBS:-4}

# --- Validation ---
if [ ! -d "$QT_SRC_DIR" ]; then
    echo "Error: QtBase source directory not found at $QT_SRC_DIR"
    exit 1
fi


# ==========================================
# QtBase
# ==========================================

# --- Configure QtBase ---
echo "Creating QtBase ohos build directory: $QT_BUILD_DIR"
mkdir -p "$QT_BUILD_DIR"
cd "$QT_BUILD_DIR"

echo "Configuring QtBase for OpenHarmony ($OHOS_TARGET_ARCH)..."
"$QT_SRC_DIR/configure" \
    -prefix "$QT_ALL_INSTALL_DIR" \
    -no-use-gold-linker \
    -no-pch \
    -nomake tests -nomake examples \
    -openssl-runtime \
    -ohos-sdk "$OHOS_SDK" \
    -ohos-arch "$OHOS_TARGET_ARCH" \
    -qt-host-path "$QT_HOST_PATH" \
    -- -DCMAKE_FIND_ROOT_PATH="$OHOS_ADDITIONAL_PACKAGES"

# --- Build QtBase ---
echo "Building QtBase ohos..."
cmake --build . --parallel "$PARALLEL_JOBS"

# --- Install QtBase ---
echo "Installing QtBase..."
cmake --install . --prefix "$QT_ALL_INSTALL_DIR"
echo "QtBase build and install complete."


# ==========================================
# QtTools
# ==========================================

# --- Configure QtTools ---
echo "Creating QtTools ohos build directory: $QTTOOLS_BUILD_DIR"
mkdir -p "$QTTOOLS_BUILD_DIR"
cd "$QTTOOLS_BUILD_DIR"
    
echo "Configuring QtTools for ohos..."
"$QT_BUILD_DIR/bin/qt-cmake" "$QTTOOLS_SRC_DIR" \
    -DCMAKE_DISABLE_FIND_PACKAGE_WrapLibClang=ON \
    -DQT_ADDITIONAL_HOST_PACKAGES_PREFIX_PATH="$PROJECT_ROOT/build/build-qttools-host" \
    -DQT_FEATURE_qtdiag=OFF
    
# --- Build QtTools ---
echo "Building QtTools ohos..."
cmake --build . --parallel "$PARALLEL_JOBS"
    
# --- Install QtTools ---
echo "Installing QtTools..."
cmake --install . --prefix "$QT_ALL_INSTALL_DIR"
echo "QtTools build and install complete."


# ==========================================
# QtSvg
# ==========================================

# --- Configure QtSvg ---
echo "Creating QtSvg ohos build directory: $QTSVG_BUILD_DIR"
mkdir -p "$QTSVG_BUILD_DIR"
cd "$QTSVG_BUILD_DIR"
    
echo "Configuring QtSvg for ohos..."
"$QT_BUILD_DIR/bin/qt-cmake" "$QTSVG_SRC_DIR" \
    -DCMAKE_DISABLE_FIND_PACKAGE_WrapLibClang=ON \
    -DQT_ADDITIONAL_HOST_PACKAGES_PREFIX_PATH="$PROJECT_ROOT/build/build-qtsvg-host"
    
# --- Build QtSvg ---
echo "Building QtSvg ohos..."
cmake --build . --parallel "$PARALLEL_JOBS"
    
# --- Install QtSvg ---
echo "Installing QtSvg..."
cmake --install . --prefix "$QT_ALL_INSTALL_DIR"
echo "QtSvg build and install complete."


# ==========================================
# QtDeclarative
# ==========================================

# --- Configure QtDeclarative ---
echo "Creating QtDeclarative ohos build directory: $QTDECLARATIVE_BUILD_DIR"
mkdir -p "$QTDECLARATIVE_BUILD_DIR"
cd "$QTDECLARATIVE_BUILD_DIR"
    
echo "Configuring QtDeclarative for ohos..."
"$QT_BUILD_DIR/bin/qt-cmake" "$QTDECLARATIVE_SRC_DIR" \
    -DCMAKE_DISABLE_FIND_PACKAGE_WrapLibClang=ON \
    -DQT_ADDITIONAL_HOST_PACKAGES_PREFIX_PATH="$PROJECT_ROOT/build/build-qtdeclarative-host"
    
# --- Build QtDeclarative ---
echo "Building QtDeclarative ohos..."
cmake --build . --parallel "$PARALLEL_JOBS"
    
# --- Install QtDeclarative ---
echo "Installing QtDeclarative..."
cmake --install . --prefix "$QT_ALL_INSTALL_DIR"
echo "QtDeclarative build and install complete."


# ==========================================
# Qt5Compat
# ==========================================

# --- Configure Qt5Compat ---
echo "Creating Qt5Compat ohos build directory: $QT5COMPAT_BUILD_DIR"
mkdir -p "$QT5COMPAT_BUILD_DIR"
cd "$QT5COMPAT_BUILD_DIR"
    
echo "Configuring Qt5Compat for ohos..."
"$QT_BUILD_DIR/bin/qt-cmake" "$QT5COMPAT_SRC_DIR" \
    -DCMAKE_DISABLE_FIND_PACKAGE_WrapLibClang=ON \
    -DQT_ADDITIONAL_HOST_PACKAGES_PREFIX_PATH="$PROJECT_ROOT/build/build-qt5compat-host"
    
# --- Build Qt5Compat ---
echo "Building Qt5Compat ohos..."
cmake --build . --parallel "$PARALLEL_JOBS"
    
# --- Install Qt5Compat ---
echo "Installing Qt5Compat..."
cmake --install . --prefix "$QT_ALL_INSTALL_DIR"
echo "Qt5Compat build and install complete."
