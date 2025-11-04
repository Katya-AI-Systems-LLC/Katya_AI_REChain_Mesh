# iOS Build & Packaging

- Requires Xcode and CocoaPods.
- `cd ios && pod install`
- Build:
  - `flutter build ios --release`
- Signing: set Team, bundle id, and capabilities in Xcode.
- BLE mesh: add Bluetooth capabilities in `Info.plist` with usage descriptions.
