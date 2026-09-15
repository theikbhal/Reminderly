#!/bin/bash
set -e

APP_NAME="Reminderly"
echo "Building ${APP_NAME}..."

swift build -c release

APP_DIR="build/${APP_NAME}.app"
rm -rf build
mkdir -p "${APP_DIR}/Contents/MacOS"
mkdir -p "${APP_DIR}/Contents/Resources"

cp .build/release/${APP_NAME} "${APP_DIR}/Contents/MacOS/${APP_NAME}"
cp Info.plist "${APP_DIR}/Contents/"
echo -n "APPL????" > "${APP_DIR}/Contents/PkgInfo"
chmod +x "${APP_DIR}/Contents/MacOS/${APP_NAME}"

echo "Build complete: ${APP_DIR}"
