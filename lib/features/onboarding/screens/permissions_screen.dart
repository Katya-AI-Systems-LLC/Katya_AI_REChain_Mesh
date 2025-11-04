import 'package:flutter/material.dart';
import 'package:katya_ai_rechain_mesh/src/utils/permission_handler.dart' as perm_handler;

class PermissionsScreen extends StatefulWidget {
  final VoidCallback onPermissionsGranted;

  const PermissionsScreen({
    super.key,
    required this.onPermissionsGranted,
  });

  @override
  _PermissionsScreenState createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool _isLoading = false;
  String _statusMessage = 'Requesting permissions...';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _statusMessage = 'Checking permissions...';
    });

    try {
      final hasPermissions = await perm_handler.PermissionHandler.hasRequiredPermissions();
      
      if (hasPermissions) {
        widget.onPermissionsGranted();
        return;
      }

      setState(() {
        _statusMessage = 'Please grant the necessary permissions to continue.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error checking permissions: $e';
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _requestPermissions() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _statusMessage = 'Requesting permissions...';
    });

    try {
      final granted = await perm_handler.PermissionHandler.requestPermissions();
      
      if (granted) {
        widget.onPermissionsGranted();
      } else {
        setState(() {
          _statusMessage = 'Please grant all permissions to use this app.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error requesting permissions: $e';
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.bluetooth,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 32),
              const Text(
                'Bluetooth Permissions Required',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'This app needs Bluetooth and Location permissions to discover and connect to nearby devices.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              if (_isLoading)
                const CircularProgressIndicator()
              else if (_hasError)
                Column(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      _statusMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: _requestPermissions,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('Grant Permissions'),
                ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  perm_handler.PermissionHandler.openAppSettings();
                },
                child: const Text('Open App Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
