#!/bin/bash
set -e

echo "Building CopyCopy..."

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

source "$ROOT_DIR/version.env"

# Build release binary using Swift Package Manager
swift build -c release

# Get the binary path
BIN_PATH="$(swift build -c release --show-bin-path)/CopyCopy"

# Create app bundle
APP_DIR="$ROOT_DIR/dist/CopyCopy.app"
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

cp "$BIN_PATH" "$APP_DIR/Contents/MacOS/CopyCopy"

GIT_COMMIT="$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")"
BUILD_TIMESTAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
MIN_VER="${MIN_SYSTEM_VERSION:-14.0}"

cat > "$APP_DIR/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key><string>en</string>
  <key>CFBundleDisplayName</key><string>${APP_NAME}</string>
  <key>CFBundleExecutable</key><string>${APP_NAME}</string>
  <key>CFBundleIdentifier</key><string>${BUNDLE_ID}</string>
  <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
  <key>CFBundleName</key><string>${APP_NAME}</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>${VERSION}</string>
  <key>CFBundleVersion</key><string>${BUILD}</string>
  <key>LSMinimumSystemVersion</key><string>${MIN_VER}</string>
  <key>LSUIElement</key><true/>
  <key>NSHighResolutionCapable</key><true/>
  <key>CopyCopyBuildTimestamp</key><string>${BUILD_TIMESTAMP}</string>
  <key>CopyCopyGitCommit</key><string>${GIT_COMMIT}</string>
  <key>CopyCopyHomepageURL</key><string>${HOMEPAGE_URL}</string>
</dict>
</plist>
PLIST

chmod +x "$APP_DIR/Contents/MacOS/CopyCopy"
chmod -R u+w "$APP_DIR"
xattr -cr "$APP_DIR" 2>/dev/null || true
find "$APP_DIR" -name '._*' -delete 2>/dev/null || true

echo ""
echo "Build complete: dist/CopyCopy.app"
