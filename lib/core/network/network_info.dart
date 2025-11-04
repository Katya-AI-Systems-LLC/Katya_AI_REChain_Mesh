import 'package:connectivity_plus/connectivity_plus.dart';

/// Network information utility
class NetworkInfo {
  final Connectivity _connectivity = Connectivity();

  /// Check if the device is connected to the internet
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Stream of connectivity changes
  Stream<ConnectivityResult> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;
}
