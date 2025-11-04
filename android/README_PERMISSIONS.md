# Android permissions & manifest snippets for BLE and Nearby

For Android 12+ (SDK 31+) and modern BLE usage you must request following permissions in AndroidManifest.xml and at runtime:

```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.BLUETOOTH_ADVERTISE" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

- For Android 10+ ACCESS_FINE_LOCATION is often required for BLE scanning on older devices.
- Request BLUETOOTH_SCAN/BLUETOOTH_CONNECT at runtime using `permission_handler` plugin or platform channels.
- Add `android:usesCleartextTraffic="true"` only if needed for debugging (not recommended in production).

Runtime example (Dart - permission_handler):
```dart
final status = await Permission.bluetoothScan.request();
if (!status.isGranted) { /* prompt user */ }
```

Additional notes:
- On some devices advertising from app is restricted; consider using foreground service or native advertising APIs.
- Update `android:targetSdkVersion` in `android/app/build.gradle` to match modern requirements.
