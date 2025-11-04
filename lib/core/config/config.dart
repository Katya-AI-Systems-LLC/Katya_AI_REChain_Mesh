import 'package:flutter/foundation.dart';

class Config {
  // Firebase Configuration
  static const String firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const String firebaseAppId = String.fromEnvironment('FIREBASE_APP_ID');
  static const String messagingSenderId = String.fromEnvironment('MESSAGING_SENDER_ID');
  static const String projectId = String.fromEnvironment('PROJECT_ID');
  static const String storageBucket = String.fromEnvironment('STORAGE_BUCKET');
  static const String authDomain = String.fromEnvironment('AUTH_DOMAIN');
  static const String measurementId = String.fromEnvironment('MEASUREMENT_ID');

  // App Configuration
  static const String appName = 'Katya AI REChain Mesh';
  static const String appVersion = '1.0.0';
  
  // API Endpoints
  static const String apiBaseUrl = kDebugMode
      ? 'http://localhost:5001/katya-ai-rechain-mesh/us-central1/api'
      : 'https://us-central1-katya-ai-rechain-mesh.cloudfunctions.net/api';

  // Feature Flags
  static const bool enableCrashlytics = true;
  static const bool enableAnalytics = true;
  static const bool enablePerformance = true;

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
