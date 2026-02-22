#!/bin/bash

# Build script for nzbwatch_core Rust library
# Supports: Android, iOS, macOS, Linux, Windows

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
RUST_DIR="$PROJECT_ROOT/packages/nzbwatch_core"
FLUTTER_DIR="$PROJECT_ROOT/packages/nzbwatch_app"

echo "Building nzbwatch_core..."
cd "$RUST_DIR"

# Function to build for Android
build_android() {
    echo "Building for Android..."
    
    # Install NDK if not present
    if ! command -v cargo-ndk &> /dev/null; then
        cargo install cargo-ndk
    fi
    
    # Build for all Android targets
    cargo ndk -t armeabi-v7a -t arm64-v8a -t x86 -t x86_64 build --release
    
    # Copy to Flutter project
    mkdir -p "$FLUTTER_DIR/android/app/src/main/jniLibs/armeabi-v7a"
    mkdir -p "$FLUTTER_DIR/android/app/src/main/jniLibs/arm64-v8a"
    mkdir -p "$FLUTTER_DIR/android/app/src/main/jniLibs/x86"
    mkdir -p "$FLUTTER_DIR/android/app/src/main/jniLibs/x86_64"
    
    cp "$RUST_DIR/target/armv7-linux-androideabi/release/libnzbwatch_core.so" \
        "$FLUTTER_DIR/android/app/src/main/jniLibs/armeabi-v7a/" 2>/dev/null || true
    cp "$RUST_DIR/target/aarch64-linux-android/release/libnzbwatch_core.so" \
        "$FLUTTER_DIR/android/app/src/main/jniLibs/arm64-v8a/" 2>/dev/null || true
    cp "$RUST_DIR/target/i686-linux-android/release/libnzbwatch_core.so" \
        "$FLUTTER_DIR/android/app/src/main/jniLibs/x86/" 2>/dev/null || true
    cp "$RUST_DIR/target/x86_64-linux-android/release/libnzbwatch_core.so" \
        "$FLUTTER_DIR/android/app/src/main/jniLibs/x86_64/" 2>/dev/null || true
    
    echo "Android build complete!"
}

# Function to build for macOS
build_macos() {
    echo "Building for macOS..."
    
    cargo build --release
    
    # Copy to Flutter project
    mkdir -p "$FLUTTER_DIR/macos/Frameworks"
    cp "$RUST_DIR/target/release/libnzbwatch_core.dylib" \
        "$FLUTTER_DIR/macos/Frameworks/" 2>/dev/null || true
    
    echo "macOS build complete!"
}

# Function to build for Linux
build_linux() {
    echo "Building for Linux..."
    
    cargo build --release
    
    # Copy to Flutter project
    mkdir -p "$FLUTTER_DIR/linux/lib"
    cp "$RUST_DIR/target/release/libnzbwatch_core.so" \
        "$FLUTTER_DIR/linux/lib/" 2>/dev/null || true
    
    echo "Linux build complete!"
}

# Function to build for iOS
build_ios() {
    echo "Building for iOS..."
    echo "iOS build requires additional setup. Skipping for now."
}

# Function to build for Windows
build_windows() {
    echo "Building for Windows..."
    
    # Check if we are on Windows or cross-compiling
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
        cargo build --release
    else
        # Assume cross-compilation from Linux/macOS
        # Requires: rustup target add x86_64-pc-windows-msvc
        # Note: This is complex on GitHub Actions without a Windows runner
        # so we will typically run this on the Windows runner itself.
        cargo build --release --target x86_64-pc-windows-msvc
    fi
    
    # Copy to Flutter project
    mkdir -p "$FLUTTER_DIR/windows/runner/resources"
    cp "$RUST_DIR/target/release/nzbwatch_core.dll" \
        "$FLUTTER_DIR/windows/runner/" 2>/dev/null || \
    cp "$RUST_DIR/target/x86_64-pc-windows-msvc/release/nzbwatch_core.dll" \
        "$FLUTTER_DIR/windows/runner/" 2>/dev/null || true
    
    echo "Windows build complete!"
}

# Parse arguments
TARGET=${1:-all}

case "$TARGET" in
    android)
        build_android
        ;;
    ios)
        build_ios
        ;;
    macos)
        build_macos
        ;;
    linux)
        build_linux
        ;;
    windows)
        build_windows
        ;;
    all)
        case "$OSTYPE" in
            linux-gnu*)
                build_linux
                build_android
                ;;
            darwin*)
                build_macos
                build_ios
                build_android
                ;;
            msys*|cygwin*|win32*)
                build_windows
                ;;
            *)
                echo "Unknown OS: $OSTYPE"
                exit 1
                ;;
        esac
        ;;
    *)
        echo "Unknown target: $TARGET"
        echo "Usage: $0 [android|ios|macos|linux|windows|all]"
        exit 1
        ;;
esac

echo "Build complete!"
