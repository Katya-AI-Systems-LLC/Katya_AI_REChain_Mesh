# Packaging instructions for Aurora (detailed)

Two approaches:

A) APK route (if device supports Android apps)
- Build APK: `flutter build apk --release`
- Install via `adb install build/app/outputs/flutter-apk/app-release.apk`
- For distribution, provide the APK and a simple installer script.

B) Native Sailfish/Aurora RPM route (no Android runtime)
- Option 1: Reimplement UI in Qt/QML and use QtBluetooth for mesh networking.
- Option 2: Use Flutter Linux embedding (advanced):
  1. Build a Linux release of your Flutter app: `flutter build linux --release` (requires desktop setup)
  2. Bundle the Flutter engine and the app snapshot into an RPM with correct dependencies.
  3. Create an RPM spec (see specfile.spec) and build with `rpmbuild -ba specfile.spec`.
- Important: test on the target device; ensure required libraries (libflutter_engine, Qt libs) are present.

Additional notes:
- For corporate Aurora variants, contact device admins for installation policies.
- Consider providing both APK and RPM artifacts for broader compatibility.
