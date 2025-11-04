import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ai_service.dart';

class OpenAIService implements AIService {
  final String apiKey;
  final String model;
  final Uri endpoint;

  OpenAIService(
      {required this.apiKey, this.model = 'gpt-4o-mini', Uri? endpoint})
      : endpoint =
            endpoint ?? Uri.parse('https://api.openai.com/v1/chat/completions');

  @override
  Future<AIResponse> generate(AIRequest request) async {
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'model': model,
      'messages': [
        {'role': 'user', 'content': request.prompt}
      ],
      'temperature': 0.2
    });
    final resp = await http.post(endpoint, headers: headers, body: body);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>?;
      final text = choices != null && choices.isNotEmpty
          ? (choices.first['message']['content'] as String? ?? '')
          : '';
      return AIResponse(text: text, metadata: {'provider': 'openai'});
    }
    throw StateError('OpenAI error: ${resp.statusCode}');
  }

  @override
  Future<void> dispose() async {}
}
