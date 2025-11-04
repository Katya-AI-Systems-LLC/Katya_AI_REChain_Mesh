import 'dart:async';
import 'ai_service.dart';
import 'tool_registry.dart';

/// Routes requests between AI providers and registered tools.
class AgentOrchestrator {
  final AIService provider;
  final ToolRegistry tools;

  AgentOrchestrator({required this.provider, required this.tools});

  Future<AIResponse> handle(AIRequest request) async {
    // Minimal orchestrator: delegate to provider for now
    return provider.generate(request);
  }
}
