import 'package:get_it/get_it.dart';
import 'package:katya_ai_rechain_mesh/src/mesh/mesh_service.dart';
import 'package:katya_ai_rechain_mesh/src/mesh/mesh_service_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // External packages
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Services
  sl.registerLazySingleton<MeshService>(
    () => MeshServiceImpl(
      localPeerName: 'Katya Device', // This should come from user settings
      deviceType: 'mobile',
    ),
  );

  // Controllers & BLoCs
  // Add your BLoCs and controllers here

  // Use cases
  // Add your use cases here

  // Repositories
  // Add your repositories here

  // Data sources
  // Add your data sources here

  // Utils
  // Add your utils here
}
