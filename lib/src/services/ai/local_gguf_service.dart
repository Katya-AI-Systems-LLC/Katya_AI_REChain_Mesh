import 'dart:async';
import 'ai_service.dart';

/// Placeholder for local gguf inference via FFI.
/// Currently echoes with a prefix; swap with real FFI binding.
class LocalGgufService implements AIService {
  @override
  Future<AIResponse> generate(AIRequest request) async {
    return AIResponse(
        text: '[gguf] ${request.prompt}', metadata: {'provider': 'gguf-stub'});
  }

  @override
  Future<void> dispose() async {}
}
