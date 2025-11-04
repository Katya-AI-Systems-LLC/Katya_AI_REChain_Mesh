import 'dart:async';

/// High-level AI service interface with pluggable providers.
abstract class AIService {
  Future<AIResponse> generate(AIRequest request);
  Future<void> dispose();
}

class AIRequest {
  final String prompt;
  final Map<String, dynamic> context;
  final List<AIToolCall> toolCalls;
  final bool allowNetwork;

  AIRequest({
    required this.prompt,
    this.context = const {},
    this.toolCalls = const [],
    this.allowNetwork = false,
  });
}

class AIResponse {
  final String text;
  final Map<String, dynamic> metadata;

  AIResponse({
    required this.text,
    this.metadata = const {},
  });
}

class AIToolCall {
  final String name;
  final Map<String, dynamic> args;

  AIToolCall(this.name, this.args);
}
