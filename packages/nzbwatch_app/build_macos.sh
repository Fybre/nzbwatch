#!/bin/bash
set -e

echo "=== NZBWatch macOS Build Script ==="

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"
RUST_DIR="$PROJECT_ROOT/packages/nzbwatch_core"
FLUTTER_DIR="$PROJECT_ROOT/packages/nzbwatch_app"

echo ""
echo "Step 1: Building Rust library..."
cd "$RUST_DIR"
cargo build --release

echo ""
echo "Step 2: Verifying library..."
LIB_PATH="$RUST_DIR/target/release/libnzbwatch_core.dylib"
if [ ! -f "$LIB_PATH" ]; then
    echo "ERROR: Library not found at $LIB_PATH"
    exit 1
fi
echo "Library built: $LIB_PATH"
ls -lh "$LIB_PATH"

echo ""
echo "Step 3: Building Flutter app..."
cd "$FLUTTER_DIR"
flutter clean
flutter pub get
flutter build macos --debug

echo ""
echo "Step 4: Copying library to app bundle..."
APP_BUNDLE="$FLUTTER_DIR/build/macos/Build/Products/Debug/nzbwatch.app"
FRAMEWORKS_DIR="$APP_BUNDLE/Contents/Frameworks"

mkdir -p "$FRAMEWORKS_DIR"
cp "$LIB_PATH" "$FRAMEWORKS_DIR/"
cp "$LIB_PATH" "$APP_BUNDLE/Contents/MacOS/"

# Step 4.1: Copy bundled par2 binary if it exists
PAR2_SRC="$PROJECT_ROOT/bin/macos/par2"
if [ -f "$PAR2_SRC" ]; then
    echo "Copying par2 binary..."
    cp "$PAR2_SRC" "$APP_BUNDLE/Contents/MacOS/"
    chmod +x "$APP_BUNDLE/Contents/MacOS/par2"
    echo "✓ par2 binary bundled"
fi

echo "Library copied to:"
echo "  - $FRAMEWORKS_DIR/libnzbwatch_core.dylib"
echo "  - $APP_BUNDLE/Contents/MacOS/libnzbwatch_core.dylib"

echo ""
echo "Step 5: Verifying app bundle..."
if [ -f "$FRAMEWORKS_DIR/libnzbwatch_core.dylib" ]; then
    echo "✓ Library is in app bundle"
else
    echo "ERROR: Library not in app bundle!"
    exit 1
fi

echo ""
echo "=== Build Complete ==="
echo ""
echo "To run the app:"
echo "  open \"$APP_BUNDLE\""
echo ""
