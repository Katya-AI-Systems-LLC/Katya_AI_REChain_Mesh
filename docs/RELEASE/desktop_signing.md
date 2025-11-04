# Desktop Packaging & Signing

Windows:
- Build: `flutter build windows --release`
- Sign: use signtool.exe with PFX certificate

macOS:
- Build: `flutter build macos --release`
- Codesign: Developer ID Application
- Notarize: `xcrun notarytool` submit + staple

Linux:
- Build: `flutter build linux --release`
- Package: DEB/RPM via fpm or native tooling
