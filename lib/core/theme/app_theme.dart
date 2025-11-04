import 'package:flutter/material.dart';

/// App Theme configuration
class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        // Add more theme customizations as needed
      );

  static ThemeData get darkTheme => ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        // Add more theme customizations as needed
      );
}
