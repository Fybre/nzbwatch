# NZBWatch - Agent Context

## Project Overview

NZBWatch is a cross-platform application for downloading and watching movies via NZB files from Usenet.

**Current Phase**: MVP (Download-then-play)
**Next Phase**: Streaming while downloading

## Architecture

### Rust Core (`packages/nzbwatch_core/`)
- **Purpose**: High-performance download engine
- **Key Modules**:
  - `nntp/`: NNTP client for Usenet communication
  - `yenc/`: yEnc decoder for binary content
  - `cache/`: File storage and segment management
  - `ffi/`: C-compatible exports for Dart interop

### Flutter App (`packages/nzbwatch_app/`)
- **Purpose**: Cross-platform UI
- **State Management**: Riverpod
- **Database**: Drift (SQLite)
- **Video Player**: media_kit
- **Key Directories**:
  - `models/`: Data classes
  - `services/`: Business logic and FFI bridge
  - `screens/`: UI screens (Library, Player, Settings)
  - `widgets/`: Reusable components

## Key Technical Decisions

1. **Rust + Flutter FFI**: Rust handles performance-critical download/decoding, Flutter handles UI
2. **Sequential Storage (MVP)**: Write segments to file at correct offset - simple, allows easy migration to streaming
3. **media_kit**: Better cross-platform video support than official video_player
4. **Drift**: Type-safe SQL with code generation

## Build Process

1. Build Rust library: `./scripts/build_rust.sh`
2. Get Flutter deps: `flutter pub get`
3. Generate code: `flutter pub run build_runner build`
4. Run: `flutter run -d <platform>`

## Important Notes

- The FFI bridge is simplified for MVP. In production, use `flutter_rust_bridge` codegen.
- NNTP connections use TLS by default (port 563)
- yEnc decoder includes CRC32 verification
- Downloads resume from where they left off (segments tracked in DB)

## Refactoring to Streaming

To add streaming capability later:
1. Add `SparseStorage` that tracks completed ranges
2. Add local HTTP server that handles Range requests
3. Modify segment scheduler to prioritize playback position
4. Video player requests from local HTTP server instead of file

The current `SequentialStorage` interface was designed to support this migration.
