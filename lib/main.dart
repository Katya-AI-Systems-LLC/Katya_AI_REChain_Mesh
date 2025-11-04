import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:katya_ai_rechain_mesh/app.dart';
import 'package:katya_ai_rechain_mesh/core/di/service_locator.dart' as di;
import 'package:katya_ai_rechain_mesh/features/onboarding/screens/permissions_screen.dart';
import 'package:katya_ai_rechain_mesh/src/utils/permission_handler.dart' as perm_handler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize service locator
  await di.init();

  // Initialize permissions
  final hasPermissions = await perm_handler.PermissionHandler.hasRequiredPermissions();

  runApp(
    ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: hasPermissions ? const App() : PermissionsScreen(
          onPermissionsGranted: () async {
            // This will be called when permissions are granted
            // The app will be rebuilt with the new permissions
            runApp(
              ProviderScope(
                child: MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: ThemeData(
                    primarySwatch: Colors.blue,
                    visualDensity: VisualDensity.adaptivePlatformDensity,
                  ),
                  home: const App(),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}
