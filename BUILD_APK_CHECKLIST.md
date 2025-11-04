# APK Build & Test Checklist (local)

1. Install Flutter SDK (stable) and ensure `flutter doctor` is clean.
2. Connect a real Android device or start an emulator with Google APIs.
3. Update Android SDK licenses and ensure `adb` works.
4. Prepare app permissions in `android/app/src/main/AndroidManifest.xml` (BLUETOOTH_* and ACCESS_FINE_LOCATION).
5. Run `flutter pub get` to install dependencies.
6. For debugging: `flutter run -d <device-id>`
7. To build release APK:
   - Enable signing in `android/app/build.gradle` or use debug signing for quick test.
   - `flutter build apk --release`
   - APK location: `build/app/outputs/flutter-apk/app-release.apk`
8. Install APK via adb:
   - `adb install -r build/app/outputs/flutter-apk/app-release.apk`
9. Test BLE functionality:
   - Ensure location & Bluetooth are enabled on device.
   - Grant runtime permissions if prompted (use `permission_handler` plugin or manually grant via settings).
10. For Aurora devices (Android runtime): install APK the same way; otherwise follow Aurora RPM packaging steps in `aurora_support/`.
