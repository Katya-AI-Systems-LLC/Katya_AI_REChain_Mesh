# Aurora OS support — notes and packaging options

Aurora OS (Аврора) is a Russian mobile OS derived from Sailfish OS. There are two practical paths to support Aurora devices:

1) **If Aurora device supports Android (APK) apps** — many Aurora deployments provide compatibility layers or Android runtime. In that case:
   - Build Android APK from this Flutter project (`flutter build apk`).
   - Install via adb or via the device's app installer.
   - Test on a real Aurora device.

2) **If Aurora is Sailfish-native and does NOT support Android apps** — provide a native Qt/QML app or package as an RPM (Sailfish uses .rpm packages):
   - Use `flutter-pi` or embed Flutter engine in a Linux package (advanced).
   - Alternatively, re-implement UI in Qt/QML and reuse Dart/Flutter business logic as a reference.
   - Package as RPM with proper manifest for Aurora device managers.

References and notes:
- Aurora OS is based on Sailfish and may not guarantee Android app compatibility — check your target device variant.
- If you target corporate Aurora devices, coordinate with device management admins to install APKs or packages.

(I verified Aurora OS is Sailfish-based and used in Russian government projects; please see web sources for details.)
