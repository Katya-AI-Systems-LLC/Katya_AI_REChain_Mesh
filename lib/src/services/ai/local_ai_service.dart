import 'dart:async';
import 'ai_service.dart';

/// Minimal offline stub provider. Can be replaced with a real local LLM.
class LocalAIService implements AIService {
  @override
  Future<AIResponse> generate(AIRequest request) async {
    final echo = '[local] ${request.prompt}';
    return AIResponse(text: echo, metadata: {'provider': 'local'});
  }

  @override
  Future<void> dispose() async {}
}
