typedef ToolHandler = Future<Map<String, dynamic>> Function(
    Map<String, dynamic> args);

class ToolRegistry {
  final Map<String, ToolHandler> _tools = {};

  void register(String name, ToolHandler handler) {
    _tools[name] = handler;
  }

  bool contains(String name) => _tools.containsKey(name);

  Future<Map<String, dynamic>> call(
      String name, Map<String, dynamic> args) async {
    final handler = _tools[name];
    if (handler == null) {
      throw StateError('Tool not registered: $name');
    }
    return handler(args);
  }
}
