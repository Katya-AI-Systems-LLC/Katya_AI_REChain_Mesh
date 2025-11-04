import 'dart:async';
import 'dart:typed_data';
import 'package:katya_ai_rechain_mesh/core/domain/entities/ai_response.dart';
import 'package:katya_ai_rechain_mesh/core/domain/repositories/ai_repository.dart';
import 'package:katya_ai_rechain_mesh/core/services/ai_service.dart';

/// Implementation of AIRepository using AIService
class AIRepositoryImpl implements AIRepository {
  final AIService _aiService;

  const AIRepositoryImpl(this._aiService);

  @override
  Future<void> initialize() => _aiService.initialize();

  @override
  Future<AIResponse> processRequest({
    required String prompt,
    required AIRequestType type,
    Map<String, dynamic>? context,
    bool useFederatedLearning = false,
  }) => _aiService.processRequest(
        prompt: prompt,
        type: type,
        context: context,
        useFederatedLearning: useFederatedLearning,
      );

  @override
  Stream<AIResponse> processRequestStream({
    required String prompt,
    required AIRequestType type,
    Map<String, dynamic>? context,
  }) => _aiService.processRequestStream(
        prompt: prompt,
        type: type,
        context: context,
      );

  @override
  Future<AIResponse> classifyText({
    required String text,
    List<String>? categories,
  }) => _aiService.classifyText(text: text, categories: categories);

  @override
  Future<AIResponse> detectIntent(String message) =>
      _aiService.detectIntent(message);

  @override
  Future<AIResponse> suggestRoute({
    required String sourcePeerId,
    required String targetPeerId,
    required List<String> availablePeers,
  }) => _aiService.suggestRoute(
        sourcePeerId: sourcePeerId,
        targetPeerId: targetPeerId,
        availablePeers: availablePeers,
      );

  @override
  Future<List<String>> suggestMessages({
    required String conversationContext,
    int maxSuggestions = 3,
  }) => _aiService.suggestMessages(
        conversationContext: conversationContext,
        maxSuggestions: maxSuggestions,
      );

  @override
  Future<AIResponse> speechToText(Uint8List audioData) =>
      _aiService.speechToText(audioData);

  @override
  Future<AIResponse> analyzeSentiment(String text) =>
      _aiService.analyzeSentiment(text);

  @override
  Future<AIResponse> optimizeRouting({
    required Map<String, dynamic> networkTopology,
    required List<String> activePeers,
  }) => _aiService.optimizeRouting(
        networkTopology: networkTopology,
        activePeers: activePeers,
      );

  @override
  Future<List<String>> recommendPeers({
    required String currentPeerId,
    required List<String> availablePeers,
    Map<String, dynamic>? preferences,
  }) => _aiService.recommendPeers(
        currentPeerId: currentPeerId,
        availablePeers: availablePeers,
        preferences: preferences,
      );

  @override
  Future<AIResponse> analyzeSecurity(String message) =>
      _aiService.analyzeSecurity(message);

  @override
  Future<AIResponse> moderateContent(String content) =>
      _aiService.moderateContent(content);

  @override
  Future<void> updateFederatedModel({
    required Map<String, dynamic> trainingData,
    required String modelType,
  }) => _aiService.updateFederatedModel(
        trainingData: trainingData,
        modelType: modelType,
      );

  @override
  Future<Map<String, dynamic>> getModelMetrics() => _aiService.getModelMetrics();

  @override
  bool get isOnDeviceAvailable => _aiService.isOnDeviceAvailable;

  @override
  bool get supportsFederatedLearning => _aiService.supportsFederatedLearning;

  @override
  List<String> get supportedModels => _aiService.supportedModels;

  @override
  Future<void> dispose() => _aiService.dispose();
}
