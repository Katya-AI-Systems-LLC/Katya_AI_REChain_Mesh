import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  /// Check and request all necessary permissions for the app
  static Future<bool> requestPermissions() async {
    try {
      // Request Bluetooth permissions for Android 12+
      if (await Permission.bluetoothConnect.request().isGranted &&
          await Permission.bluetoothScan.request().isGranted &&
          await Permission.bluetoothAdvertise.request().isGranted) {
        // Request location permission (required for BLE scanning on Android)
        if (await Permission.locationWhenInUse.request().isGranted) {
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Check if all required permissions are granted
  static Future<bool> hasRequiredPermissions() async {
    try {
      return await Permission.bluetoothConnect.isGranted &&
          await Permission.bluetoothScan.isGranted &&
          await Permission.bluetoothAdvertise.isGranted &&
          await Permission.locationWhenInUse.isGranted;
    } catch (e) {
      return false;
    }
  }

  /// Open app settings so user can manually grant permissions
  static Future<bool> openAppSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      return false;
    }
  }
}
