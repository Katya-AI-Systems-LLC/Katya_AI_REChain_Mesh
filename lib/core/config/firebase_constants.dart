class FirebaseConstants {
  // Firebase project configuration
  static const String projectId = 'katya-ai-rechain-mesh';
  static const String webApiKey = 'YOUR_WEB_API_KEY';
  static const String appId = 'YOUR_APP_ID';
  static const String messagingSenderId = 'YOUR_MESSAGING_SENDER_ID';
  static const String authDomain = '$projectId.firebaseapp.com';
  static const String storageBucket = '$projectId.appspot.com';
  static const String measurementId = 'YOUR_MEASUREMENT_ID';
  
  // Collections
  static const String usersCollection = 'users';
  static const String messagesCollection = 'messages';
  static const String nodesCollection = 'nodes';
  static const String votesCollection = 'votes';
  
  // Storage paths
  static const String profileImagesPath = 'profile_images';
  static const String messageAttachmentsPath = 'message_attachments';
  
  // Remote Config defaults
  static const Map<String, dynamic> remoteConfigDefaults = {
    'feature_mesh_networking': true,
    'feature_offline_mode': true,
    'feature_quantum_safe': false,
    'max_peers': 10,
    'message_ttl_seconds': 3600,
    'enable_analytics': true,
    'enable_crashlytics': true,
  };
  
  // Emulator settings
  static const bool useEmulator = true;
  static const String emulatorHost = 'localhost';
  static const int firestorePort = 8080;
  static const int authPort = 9099;
  static const int storagePort = 9199;
  static const int functionsPort = 5001;
}
