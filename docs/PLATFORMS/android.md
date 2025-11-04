# Android Build & Packaging

- Min SDK: from `android/app/build.gradle` via `flutter.minSdkVersion`
- Permissions: see `android/app/src/main/AndroidManifest.xml`
- Build release APK:
  - `flutter build apk --release`
- Signing: configure `key.properties` and `build.gradle`
- BLE mesh notes: ensure Bluetooth permissions and location are granted.
