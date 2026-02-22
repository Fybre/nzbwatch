# NZBWatch

A cross-platform NZB downloader and media streamer for Windows, Linux, macOS, Android, and iOS.

## Features

- **Download NZB files** from Usenet servers
- **Stream media** while downloading (MVP: download-then-play)
- **Cross-platform** - one codebase for all platforms
- **Modern UI** with dark theme
- **Multiple server support** with priority and connection limits

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  Flutter UI (Dart)                                          │
│  - Library screen                                           │
│  - Player (media_kit)                                       │
│  - Settings                                                 │
└──────────────────────┬──────────────────────────────────────┘
                       │ FFI
┌──────────────────────▼──────────────────────────────────────┐
│  Rust Core                                                  │
│  - NNTP client (async)                                      │
│  - yEnc decoder                                             │
│  - Download orchestrator                                    │
│  - Segment cache                                            │
└─────────────────────────────────────────────────────────────┘
```

## Project Structure

```
nzbwatch/
├── packages/
│   ├── nzbwatch_core/          # Rust core engine
│   │   ├── src/
│   │   │   ├── nntp/           # NNTP protocol implementation
│   │   │   ├── yenc/           # yEnc decoder
│   │   │   ├── cache/          # Segment storage
│   │   │   └── ffi/            # FFI exports
│   │   └── Cargo.toml
│   │
│   └── nzbwatch_app/           # Flutter application
│       ├── lib/
│       │   ├── models/         # Data models
│       │   ├── providers/      # Riverpod state
│       │   ├── services/       # Business logic
│       │   ├── screens/        # UI screens
│       │   └── widgets/        # Reusable widgets
│       └── pubspec.yaml
│
└── scripts/
    └── build_rust.sh           # Build script for Rust library
```

## Prerequisites

- **Flutter** 3.10+ with Dart 3.0+
- **Rust** 1.70+ with Cargo
- **Android SDK** (for Android builds)
- **Xcode** (for iOS/macOS builds)

## Building

### 1. Build the Rust Core

```bash
# Build for current platform
./scripts/build_rust.sh

# Or build for specific platform
./scripts/build_rust.sh android
./scripts/build_rust.sh macos
./scripts/build_rust.sh linux
```

### 2. Install Flutter Dependencies

```bash
cd packages/nzbwatch_app
flutter pub get
```

### 3. Generate Code

```bash
# Generate drift database code
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Run the App

```bash
# Desktop (Linux/macOS/Windows)
flutter run -d linux
flutter run -d macos
flutter run -d windows

# Mobile
flutter run -d android
flutter run -d ios
```

## Usage

1. **Configure a Usenet Server**
   - Go to Settings → Add Server
   - Enter your server details (host, port, SSL, credentials)
   - Test the connection

2. **Add a Download**
   - Tap the "Add NZB" button
   - Paste the NZB XML or import from file
   - The download starts automatically

3. **Watch Downloaded Content**
   - Once complete, tap a download to play
   - Uses media_kit for playback

## Configuration

### Server Settings

| Setting | Description | Default |
|---------|-------------|---------|
| Host | Usenet server hostname | - |
| Port | Server port | 563 (SSL) or 119 |
| SSL | Use SSL/TLS encryption | true |
| Username | Authentication username | - |
| Password | Authentication password | - |
| Max Connections | Simultaneous connections | 4 |
| Priority | Server priority (lower = higher) | 0 |

## Development

### Running Tests

```bash
# Rust tests
cd packages/nzbwatch_core
cargo test

# Flutter tests
cd packages/nzbwatch_app
flutter test
```

### Code Generation

After modifying database tables or models:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Adding New Platforms

The app uses Flutter's multi-platform support:

1. **Android**: Configured in `android/` directory
2. **iOS**: Configured in `ios/` directory  
3. **macOS**: Configured in `macos/` directory
4. **Linux**: Configured in `linux/` directory
5. **Windows**: Configured in `windows/` directory

Each platform requires the Rust library to be built and placed in the appropriate location.

## Roadmap

### MVP (Current)
- ✅ Download NZB files to completion
- ✅ Play downloaded files (Subtitles, Audio, Fullscreen)
- ✅ Server configuration
- ✅ Health tracking and pre-download availability check
- ✅ Automatic RAR extraction
- ✅ Post-processing failure detection and retry

### Future
- 🔄 **Streaming** - Watch while downloading
- 🔄 **Seek during download** - Jump to any position
- 🔄 **PAR repair** - Integration with par2cmdline
- 🔄 **Queue management** - Pause/resume/priority
- 🔄 **Speed limiting** - Bandwidth control

## Technical Notes

### NNTP Protocol
The app implements the Network News Transfer Protocol (NNTP) for downloading articles from Usenet servers. Each file is split into multiple articles (segments) that are downloaded and reassembled.

### yEnc Encoding
yEnc is the encoding scheme used for binary content on Usenet. The Rust core includes a fast yEnc decoder with CRC32 verification.

### File Assembly
For the MVP, segments are written directly to the output file at their correct offsets. This allows immediate playback once complete.

### Future Streaming
The sparse file approach (writing at correct offsets) is the foundation for streaming. The next phase will add:
1. HTTP server for range requests
2. Priority queue for segment ordering
3. Buffer management for smooth playback

## License

MIT License - See LICENSE file

## Acknowledgments

- [media_kit](https://github.com/media-kit/media-kit) - Cross-platform video playback
- [par2cmdline](https://github.com/Parchive/par2cmdline) - Standard Usenet repair tool (Bundled)
- [unrar](https://github.com/rarw/unrar) - RAR extraction engine
- [Drift](https://drift.simonbinder.eu/) - Dart SQL database
- [Riverpod](https://riverpod.dev/) - State management
- [Tokio](https://tokio.rs/) - Rust async runtime
