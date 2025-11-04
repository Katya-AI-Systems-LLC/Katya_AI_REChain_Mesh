import 'dart:convert';
import 'package:http/http.dart' as http;
// note: not real import; read file instead

class BackendClient {
  final String baseUrl;
  BackendClient(this.baseUrl);

  Future<List<dynamic>> fetchMessages() async {
    try {
      final res = await http.get(Uri.parse('\$baseUrl/sync'));
      if (res.statusCode == 200) {
        return jsonDecode(res.body)['messages'] as List<dynamic>;
      }
    } catch (e) {}
    return [];
  }

  Future<bool> postMessage(Map<String, dynamic> msg) async {
    try {
      final res = await http.post(
        Uri.parse('\$baseUrl/sync'),
        body: jsonEncode(msg),
        headers: {'Content-Type': 'application/json'},
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
