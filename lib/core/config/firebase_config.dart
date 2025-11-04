import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_functions/firebase_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:katya_ai_rechain_mesh/core/config/firebase_constants.dart';
import 'package:katya_ai_rechain_mesh/core/error/firebase_exceptions.dart';

/// Manages Firebase initialization and configuration for the app.
class FirebaseConfig {
  static final FirebaseConfig _instance = FirebaseConfig._internal();
  static FirebaseConfig get instance => _instance;
  FirebaseConfig._internal();

  // Firebase services
  late final FirebaseApp app;
  late final FirebaseAuth auth;
  late final FirebaseFirestore firestore;
  late final FirebaseStorage storage;
  late final FirebaseAnalytics analytics;
  late final FirebaseCrashlytics crashlytics;
  late final FirebasePerformance performance;
  late final FirebaseRemoteConfig remoteConfig;
  late final FirebaseMessaging messaging;
  late final FirebaseFunctions functions;
  late final FirebaseDynamicLinks dynamicLinks;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  
  /// Initialize Firebase services
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Firebase
      app = await Firebase.initializeApp(
        name: FirebaseConstants.projectId,
        options: FirebaseOptions(
          apiKey: FirebaseConstants.webApiKey,
          appId: FirebaseConstants.appId,
          messagingSenderId: FirebaseConstants.messagingSenderId,
          projectId: FirebaseConstants.projectId,
          storageBucket: FirebaseConstants.storageBucket,
        ),
      );

      // Initialize services
      auth = FirebaseAuth.instance;
      firestore = FirebaseFirestore.instance;
      storage = FirebaseStorage.instance;
      analytics = FirebaseAnalytics.instance;
      crashlytics = FirebaseCrashlytics.instance;
      performance = FirebasePerformance.instance;
      remoteConfig = FirebaseRemoteConfig.instance;
      messaging = FirebaseMessaging.instance;
      functions = FirebaseFunctions.instance;
      dynamicLinks = FirebaseDynamicLinks.instance;

      // Configure emulators in debug mode
      if (kDebugMode) {
        await _configureEmulators();
      }

      // Configure crashlytics
      await _configureCrashlytics();

      // Configure remote config
      await _configureRemoteConfig();

      _isInitialized = true;
      debugPrint('✅ Firebase initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to initialize Firebase: $e');
      throw FirebaseInitializationException(
        message: 'Failed to initialize Firebase',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Configures Firebase emulators for local development
  Future<void> _configureEmulators() async {
    if (!FirebaseConstants.useEmulator) return;

    try {
      final host = Platform.isAndroid ? '10.0.2.2' : FirebaseConstants.emulatorHost;

      // Configure Firestore emulator
      firestore.useFirestoreEmulator(host, FirebaseConstants.firestorePort);

      // Configure Auth emulator
      await auth.useAuthEmulator(host, FirebaseConstants.authPort);

      // Configure Storage emulator
      storage.useStorageEmulator(
        host,
        FirebaseConstants.storagePort,
      );

      // Configure Functions emulator
      functions.useFunctionsEmulator(
        host,
        FirebaseConstants.functionsPort,
      );

      debugPrint('🔥 Firebase emulators configured successfully');
    } catch (e) {
      debugPrint('⚠️ Failed to configure Firebase emulators: $e');
      // Don't throw, as emulators are for development only
    }
  }

  // Platform-specific configurations
  FirebaseOptions get _currentPlatform {
    if (kIsWeb) {
      return _web;
    }
    switch (Platform.operatingSystem) {
      case 'android':
        return _android;
      case 'ios':
        return _ios;
      case 'macos':
        return _macos;
      case 'windows':
        return _windows;
      case 'linux':
        return _linux;
      default:
        throw UnsupportedError('Platform not supported: ${Platform.operatingSystem}');
    }
  }

  final FirebaseOptions _web = FirebaseOptions(
    apiKey: FirebaseConstants.webApiKey,
    appId: FirebaseConstants.appId,
    messagingSenderId: FirebaseConstants.messagingSenderId,
    projectId: FirebaseConstants.projectId,
    authDomain: FirebaseConstants.authDomain,
    storageBucket: FirebaseConstants.storageBucket,
    measurementId: FirebaseConstants.measurementId,
  );

  final FirebaseOptions _android = FirebaseOptions(
    apiKey: FirebaseConstants.webApiKey,
    appId: FirebaseConstants.appId,
    messagingSenderId: FirebaseConstants.messagingSenderId,
    projectId: FirebaseConstants.projectId,
    storageBucket: FirebaseConstants.storageBucket,
  );

  final FirebaseOptions _ios = FirebaseOptions(
    apiKey: FirebaseConstants.webApiKey,
    appId: FirebaseConstants.appId,
    messagingSenderId: FirebaseConstants.messagingSenderId,
    projectId: FirebaseConstants.projectId,
    storageBucket: FirebaseConstants.storageBucket,
    iosClientId: '${FirebaseConstants.appId}.apps.googleusercontent.com',
    iosBundleId: 'com.katyaai.rechainmesh',
  );

  final FirebaseOptions _macos = FirebaseOptions(
    apiKey: FirebaseConstants.webApiKey,
    appId: FirebaseConstants.appId,
    messagingSenderId: FirebaseConstants.messagingSenderId,
    projectId: FirebaseConstants.projectId,
    storageBucket: FirebaseConstants.storageBucket,
    iosClientId: '${FirebaseConstants.appId}.apps.googleusercontent.com',
    iosBundleId: 'com.katyaai.rechainmesh',
  );

  final FirebaseOptions _windows = FirebaseOptions(
    apiKey: FirebaseConstants.webApiKey,
    appId: FirebaseConstants.appId,
    messagingSenderId: FirebaseConstants.messagingSenderId,
    projectId: FirebaseConstants.projectId,
    storageBucket: FirebaseConstants.storageBucket,
  );

  final FirebaseOptions _linux = FirebaseOptions(
    apiKey: FirebaseConstants.webApiKey,
    appId: FirebaseConstants.appId,
    messagingSenderId: FirebaseConstants.messagingSenderId,
    projectId: FirebaseConstants.projectId,
    storageBucket: FirebaseConstants.storageBucket,
  );

  /// Initializes Firebase and its services
  Future<void> initialize() async {
    try {
      // Initialize Firebase Core
      await Firebase.initializeApp(
        options: _currentPlatform,
      );

      // Initialize Firebase services
      await _initializeFirebaseServices();

      // Configure debug features if in debug mode
      if (kDebugMode) {
        await _enableDebugFeatures();
      }

      debugPrint('✅ Firebase initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to initialize Firebase: $e');
      debugPrintStack(stackTrace: stackTrace);

      // Rethrow with more context
      throw FirebaseInitializationException(
        message: 'Failed to initialize Firebase',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _initializeFirebaseServices() async {
    try {
      // Initialize Remote Config
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      // Set default values for Remote Config from constants
      await remoteConfig.setDefaults(FirebaseConstants.remoteConfigDefaults);

      // Fetch and activate Remote Config values
      await remoteConfig.fetchAndActivate();
      debugPrint('✅ Remote Config initialized');

      // Configure Firestore
      await _configureFirestore();

      // Configure emulators if enabled
      if (FirebaseConstants.useEmulator) {
        await _configureEmulators();
      }

    } catch (e) {
      debugPrint('Error initializing Firebase services: $e');
      if (kDebugMode) {
        rethrow; // Only throw in debug mode to prevent app crashes in production
      }
    }
  }

  /// Configures Firestore with offline persistence
  Future<void> _configureFirestore() async {
    if (!kIsWeb) {
      // Enable offline persistence
      firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    }
  }

  /// Configures Crashlytics for error reporting
  Future<void> _configureCrashlytics() async {
    // Enable crashlytics collection in production
    await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

    // Record Flutter errors
    FlutterError.onError = crashlytics.recordFlutterFatalError;
  }

  /// Configures Remote Config
  Future<void> _configureRemoteConfig() async {
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));

    await remoteConfig.setDefaults(FirebaseConstants.remoteConfigDefaults);
    await remoteConfig.fetchAndActivate();
  }

  /// Enables debug features for development
  Future<void> _enableDebugFeatures() async {
    // Configure emulators for local development
    if (FirebaseConstants.useEmulator) {
      await _configureEmulators();
      debugPrint('Connected to Firebase emulators');
    }
  }
}
