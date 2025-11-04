import 'package:katya_ai_rechain_mesh/core/domain/entities/ai_response.dart';
import 'package:katya_ai_rechain_mesh/core/domain/repositories/ai_repository.dart';
import 'package:katya_ai_rechain_mesh/core/utils/result.dart';

/// Use case for processing AI requests with on-device inference
class ProcessAIRequestUseCase {
  final AIRepository _repository;

  const ProcessAIRequestUseCase(this._repository);

  /// Execute the AI processing operation
  Future<Result<AIResponse>> call({
    required String prompt,
    required AIRequestType type,
    Map<String, dynamic>? context,
    bool useFederatedLearning = false,
  }) async {
    try {
      final response = await _repository.processRequest(
        prompt: prompt,
        type: type,
        context: context,
        useFederatedLearning: useFederatedLearning,
      );
      return Result.success(response);
    } catch (e) {
      return Result.failure('Failed to process AI request: $e');
    }
  }
}

/// Types of AI requests supported
enum AIRequestType {
  textClassification,
  intentDetection,
  smartRouting,
  messageSuggestion,
  voiceToText,
  sentimentAnalysis,
}
