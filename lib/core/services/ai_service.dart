import 'dart:async';
import 'dart:typed_data';
import 'package:katya_ai_rechain_mesh/core/domain/entities/ai_response.dart';

/// Abstract interface for AI processing service
abstract class AIService {
  /// Initialize the AI system
  Future<void> initialize();

  /// Process an AI request with on-device inference
  Future<AIResponse> processRequest({
    required String prompt,
    required AIRequestType type,
    Map<String, dynamic>? context,
    bool useFederatedLearning = false,
  });

  /// Stream real-time AI processing results
  Stream<AIResponse> processRequestStream({
    required String prompt,
    required AIRequestType type,
    Map<String, dynamic>? context,
  });

  /// Classify text content
  Future<AIResponse> classifyText({
    required String text,
    List<String>? categories,
  });

  /// Detect user intent from message
  Future<AIResponse> detectIntent(String message);

  /// Generate smart routing suggestions
  Future<AIResponse> suggestRoute({
    required String sourcePeerId,
    required String targetPeerId,
    required List<String> availablePeers,
  });

  /// Generate message suggestions
  Future<List<String>> suggestMessages({
    required String conversationContext,
    int maxSuggestions = 3,
  });

  /// Convert speech to text
  Future<AIResponse> speechToText(Uint8List audioData);

  /// Analyze sentiment of text
  Future<AIResponse> analyzeSentiment(String text);

  /// Optimize mesh routing using AI
  Future<AIResponse> optimizeRouting({
    required Map<String, dynamic> networkTopology,
    required List<String> activePeers,
  });

  /// Recommend peers for connection
  Future<List<String>> recommendPeers({
    required String currentPeerId,
    required List<String> availablePeers,
    Map<String, dynamic>? preferences,
  });

  /// Analyze security threats in messages
  Future<AIResponse> analyzeSecurity(String message);

  /// Moderate content for appropriateness
  Future<AIResponse> moderateContent(String content);

  /// Train/update AI models with federated learning
  Future<void> updateFederatedModel({
    required Map<String, dynamic> trainingData,
    required String modelType,
  });

  /// Get AI model performance metrics
  Future<Map<String, dynamic>> getModelMetrics();

  /// Check if AI processing is available on-device
  bool get isOnDeviceAvailable;

  /// Check if federated learning is supported
  bool get supportsFederatedLearning;

  /// Get supported AI model types
  List<String> get supportedModels;

  /// Clean up AI resources
  Future<void> dispose();
}
