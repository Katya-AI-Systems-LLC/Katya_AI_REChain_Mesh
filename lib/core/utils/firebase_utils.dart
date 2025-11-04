import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:katya_ai_rechain_mesh/core/error/firebase_exceptions.dart';

/// A utility class for initializing and configuring Firebase services.
class FirebaseUtils {
  /// Initializes Firebase services with the provided options.
  /// 
  /// Throws [FirebaseInitializationException] if initialization fails.
  static Future<void> initializeFirebase({
    FirebaseOptions? options,
    bool useEmulator = kDebugMode,
  }) async {
    try {
      // Initialize Firebase Core
      await Firebase.initializeApp(
        options: options,
      );

      // Configure emulators in debug mode if requested
      if (useEmulator && !kIsWeb) {
        await _configureEmulators();
      }

      // Initialize other Firebase services
      await Future.wait([
        _initializeCrashlytics(),
        _initializePerformance(),
        _initializeRemoteConfig(),
      ]);
    } catch (e, stackTrace) {
      throw FirebaseInitializationException(
        message: 'Failed to initialize Firebase services',
        stackTrace: stackTrace,
      );
    }
  }

  /// Configures Firebase emulators for local development.
  static Future<void> _configureEmulators() async {
    try {
      const host = 'localhost';
      
      // Configure Firestore emulator
      FirebaseFirestore.instance.settings = const Settings(
        host: '$host:8080',
        sslEnabled: false,
        persistenceEnabled: true,
      );

      // Configure Auth emulator
      await FirebaseAuth.instance.useAuthEmulator(host, 9099);

      // Configure Storage emulator
      await FirebaseStorage.instance.useStorageEmulator(host, 9199);

      // Configure Functions emulator
      FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);

      if (kDebugMode) {
        print('Firebase emulators configured successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to configure Firebase emulators: $e');
      }
    }
  }

  /// Initializes Firebase Crashlytics.
  static Future<void> _initializeCrashlytics() async {
    if (kDebugMode) {
      // Enable Crashlytics in debug mode for testing
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      
      // Force a test crash to verify Crashlytics is working
      // FirebaseCrashlytics.instance.crash();
    }
  }

  /// Initializes Firebase Performance Monitoring.
  static Future<void> _initializePerformance() async {
    if (kDebugMode) {
      await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
    }
  }

  /// Initializes Firebase Remote Config.
  static Future<void> _initializeRemoteConfig() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    
    // Set default values
    await remoteConfig.setDefaults(const {
      'feature_mesh_networking': true,
      'feature_offline_mode': true,
      'feature_quantum_safe': false,
      'max_peers': '10',
      'message_ttl_seconds': '3600',
    });

    try {
      // Fetch and activate remote config
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: kDebugMode 
            ? const Duration(minutes: 5)  // Shorter interval for development
            : const Duration(hours: 1),   // Longer interval for production
      ));

      await remoteConfig.fetchAndActivate();
      
      if (kDebugMode) {
        print('Remote Config initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize Remote Config: $e');
      }
    }
  }

  /// Gets the current Firebase user, or null if not authenticated.
  static User? get currentUser => FirebaseAuth.instance.currentUser;

  /// Checks if a user is currently signed in.
  static bool get isUserSignedIn => FirebaseAuth.instance.currentUser != null;

  /// Gets the current user's ID, or null if not authenticated.
  static String? get currentUserId => currentUser?.uid;

  /// Gets the current user's authentication token, or null if not authenticated.
  static Future<String?> getAuthToken() async {
    try {
      return await currentUser?.getIdToken();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get auth token: $e');
      }
      return null;
    }
  }

  /// Signs out the current user.
  static Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e, stackTrace) {
      throw FirebaseAuthException(
        message: 'Failed to sign out',
        code: 'sign-out-failed',
        stackTrace: stackTrace,
      );
    }
  }

  /// Handles Firebase errors and converts them to appropriate exceptions.
  static dynamic handleFirebaseError(dynamic error, StackTrace stackTrace) {
    if (error is FirebaseException) {
      // Handle specific Firebase errors
      switch (error.plugin) {
        case 'firebase_auth':
          return FirebaseAuthException(
            message: error.message ?? 'Authentication failed',
            code: error.code,
            email: (error as dynamic).email,
            stackTrace: stackTrace,
          );
        case 'cloud_firestore':
          return FirestoreException(
            message: error.message ?? 'Firestore operation failed',
            code: error.code,
            stackTrace: stackTrace,
          );
        case 'firebase_storage':
          return StorageException(
            message: error.message ?? 'Storage operation failed',
            code: error.code,
            path: (error as dynamic).path,
            stackTrace: stackTrace,
          );
        default:
          return FirebaseInitializationException(
            message: 'Firebase error: ${error.message}',
            stackTrace: stackTrace,
          );
      }
    }
    return error;
  }
}
