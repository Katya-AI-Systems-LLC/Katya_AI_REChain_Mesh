# Linux Platform Development

This directory contains the Linux-specific implementation for the Katya AI REChain Mesh project using Flutter.

## Structure

- **flutter/**: Flutter configurations for Linux.
- **CMakeLists.txt**: CMake build script.
- **build.gradle**: Gradle script.
- **katya-ai-rechain-mesh.desktop**: Desktop entry file.
- **katya-ai-rechain-mesh.service**: Systemd service file.
- **katya-ai-rechain-mesh.apparmor**: AppArmor profile.

## Development Setup

1. **Prerequisites**:
   - Install Flutter SDK.
   - Install necessary Linux dependencies (e.g., via `flutter doctor`).
   - Ensure GTK development libraries are installed.

2. **Building the App**:
   - Run `flutter pub get`.
   - Use `flutter build linux` to build.
   - Optionally, use `cmake` for native builds.

3. **Features**:
   - Blockchain modules via Flutter plugins.
   - Gaming and IoT support.
   - Social features in Dart.
   - Desktop integration with .desktop file and service.

## Customization

- Edit `lib/` for app logic.
- Modify Linux-specific files for desktop integration (e.g., icons, menus).

## Documentation

Refer to Flutter Linux documentation and the project's README.

## Testing

- Use `flutter test`.
- Run on Linux for integration testing.

For support, check project issues.
