import 'tool_registry.dart';
import '../mesh_service_ble.dart';
import '../voting_service.dart';

void registerExampleTools(ToolRegistry registry) {
  registry.register('mesh.stats', (args) async {
    final stats = MeshServiceBLE.instance.getMeshStatistics();
    return stats;
  });

  registry.register('voting.summary', (args) async {
    final voting = VotingService();
    // Assuming singleton or accessible instance; if not, adapt to injected instance
    final s = voting.getStatistics();
    return {'total_polls': s['total_polls'], 'total_votes': s['total_votes']};
  });
}
