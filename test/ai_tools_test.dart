import 'package:flutter_test/flutter_test.dart';
import 'package:katya_ai_rechain_mesh/src/services/ai/tool_registry.dart';
import 'package:katya_ai_rechain_mesh/src/services/ai/tools_examples.dart';

void main() {
  test('Tool registry registers example tools', () async {
    final reg = ToolRegistry();
    registerExampleTools(reg);
    expect(reg.contains('mesh.stats'), true);
    expect(reg.contains('voting.summary'), true);
  });
}
