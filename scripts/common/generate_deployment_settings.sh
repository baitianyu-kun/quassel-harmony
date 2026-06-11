#!/bin/bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." &> /dev/null && pwd )"

# --- SDK Path ---
export OHOS_SDK="$TOOL_HOME/sdk/default/openharmony"
# Allows overriding SDK and NDK paths via environment variables if needed
SDK_ROOT=$OHOS_SDK
NDK_ROOT=$OHOS_SDK/native

OUTPUT_FILE="$SCRIPT_DIR/quassel-harmony-deployment-settings.json"

cat > "$OUTPUT_FILE" <<EOF
{
    "application-binary": "$PROJECT_ROOT/build/build-quassel-ohos/libquasselclient.so",
    "harmonyos-app-name": "quassel",
    "harmonyos-app-bundle-name": "com.ohos.quassel",
    "harmonyos-target-arch": ["arm64-v8a"],
    "sdk-root": "$SDK_ROOT",
    "ndk-root": "$NDK_ROOT",
    "qtLibsDirectory": "$PROJECT_ROOT/build/build-qt-ohos-install/lib",
    "qtPluginsDirectory": "$PROJECT_ROOT/build/build-qt-ohos-install/plugins",
    "qtQmlDirectory": "$PROJECT_ROOT/build/build-qt-ohos-install/qml",
    "qtLibExecsDirectory": "$PROJECT_ROOT/build/build-qt-host-install/libexec",
    "qtHostDirectory": "$PROJECT_ROOT/build/build-qt-host-install",
    "harmonyos-package-source-directory": "$PROJECT_ROOT/build/build-qt-ohos-install/src/harmonyos/templates",
    "extra-libs-dirs": [
        "$PROJECT_ROOT/additional-packages/lib",
        "$PROJECT_ROOT/build/build-quassel-ohos/lib"
    ],
    "permissions": [
        { "name": "ohos.permission.INTERNET" },
        { "name": "ohos.permission.GET_NETWORK_INFO" },
        { "name": "ohos.permission.KEEP_BACKGROUND_RUNNING" }
    ],
    "project-libraries": [
        "$PROJECT_ROOT/build/build-qt-ohos-install/lib/libQt6Core.so",
        "$PROJECT_ROOT/build/build-qt-ohos-install/lib/libQt6Gui.so",
        "$PROJECT_ROOT/build/build-qt-ohos-install/lib/libQt6Widgets.so",
        "$PROJECT_ROOT/build/build-qt-ohos-install/lib/libQt6Network.so",
        "$PROJECT_ROOT/build/build-qt-ohos-install/lib/libQt6Sql.so",
        "$PROJECT_ROOT/build/build-qt-ohos-install/lib/libQt6Core5Compat.so",
        "$PROJECT_ROOT/build/build-qt-ohos-install/lib/libQt6DBus.so"
    ]
}
EOF

echo "Successfully generated \$OUTPUT_FILE"
