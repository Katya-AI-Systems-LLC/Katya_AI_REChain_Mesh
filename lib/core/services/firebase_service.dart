import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:katya_ai_rechain_mesh/core/error/exceptions.dart';
import 'package:katya_ai_rechain_mesh/core/network/network_info.dart';
import 'package:katya_ai_rechain_mesh/src/mesh/models/mesh_message.dart';
import 'package:katya_ai_rechain_mesh/src/mesh/models/peer_info.dart';

class FirebaseService {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  final FirebasePerformance _performance = FirebasePerformance.instance;
  final NetworkInfo _networkInfo;

  // Remote Config
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  FirebaseService({required NetworkInfo networkInfo})
      : _networkInfo = networkInfo;

  // Auth Methods
  Stream<auth.User?> get authStateChanges => _auth.authStateChanges();

  Future<auth.UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on auth.FirebaseAuthException catch (e) {
      throw ServerException(message: e.message ?? 'Authentication failed');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // User Profile
  Future<void> updateUserProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final userDoc = _firestore.collection('users').doc(userId);

      await userDoc.set({
        'displayName': displayName,
        'photoURL': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
        ...?additionalData,
      }, SetOptions(merge: true));

      // Update auth user profile if needed
      if (displayName != null || photoUrl != null) {
        await _auth.currentUser?.updateDisplayName(displayName);
        if (photoUrl != null) {
          await _auth.currentUser?.updatePhotoURL(photoUrl);
        }
      }
    } catch (e) {
      throw ServerException(message: 'Failed to update profile: $e');
    }
  }

  // Mesh Messaging
  Stream<List<MeshMessage>> getMessages({
    required String userId,
    String? peerId,
    int limit = 50,
  }) {
    try {
      Query query = _firestore
          .collection('meshMessages')
          .where('recipientIds', arrayContains: userId)
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (peerId != null) {
        query = query.where('senderId', isEqualTo: peerId);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => MeshMessage.fromJson(doc.data()))
            .toList();
      });
    } catch (e) {
      throw ServerException(message: 'Failed to fetch messages: $e');
    }
  }

  Future<void> sendMessage(MeshMessage message) async {
    try {
      await _firestore.collection('meshMessages').add(message.toJson());
    } catch (e) {
      throw ServerException(message: 'Failed to send message: $e');
    }
  }

  // File Upload
  Future<String> uploadFile({
    required String path,
    required Uint8List fileData,
    String? mimeType,
    Map<String, String>? metadata,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putData(
        fileData,
        SettableMetadata(
          contentType: mimeType,
          customMetadata: metadata ?? {},
        ),
      );

      final snapshot = await uploadTask.whenComplete(() => null);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw ServerException(message: 'File upload failed: $e');
    }
  }

  // Remote Config
  Future<void> fetchRemoteConfig() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch remote config: $e');
    }
  }

  // Analytics & Crash Reporting
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  Future<void> recordError(dynamic error, StackTrace stackTrace) async {
    await _crashlytics.recordError(
      error,
      stackTrace,
      reason: 'A non-fatal error occurred',
      printDetails: true,
    );
  }

  // FCM Token Management
  Future<String?> getFcmToken() async {
    try {
      if (!await _messaging.isSupported()) return null;

      String? token = await _messaging.getToken();
      await _updateFcmToken(token);
      return token;
    } catch (e) {
      return null;
    }
  }

  Future<void> _updateFcmToken(String token) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Cleanup
  void dispose() {
    // Add any necessary cleanup here
  }
}
