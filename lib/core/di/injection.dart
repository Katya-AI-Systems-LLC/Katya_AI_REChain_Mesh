import 'package:get_it/get_it.dart';
import 'package:katya_ai_rechain_mesh/core/domain/usecases/discover_peers_usecase.dart';
import 'package:katya_ai_rechain_mesh/core/domain/usecases/send_message_usecase.dart';
import 'package:katya_ai_rechain_mesh/core/domain/usecases/encrypt_message_usecase.dart';
import 'package:katya_ai_rechain_mesh/core/domain/usecases/process_ai_request_usecase.dart';
import 'package:katya_ai_rechain_mesh/core/domain/repositories/mesh_repository.dart';
import 'package:katya_ai_rechain_mesh/core/domain/repositories/crypto_repository.dart';
import 'package:katya_ai_rechain_mesh/core/domain/repositories/ai_repository.dart';
import 'package:katya_ai_rechain_mesh/core/services/mesh_service.dart';
import 'package:katya_ai_rechain_mesh/core/services/crypto_service.dart';
import 'package:katya_ai_rechain_mesh/core/services/ai_service.dart';
import 'package:katya_ai_rechain_mesh/core/services/quantum_service.dart';
import 'package:katya_ai_rechain_mesh/infrastructure/repositories/mesh_repository_impl.dart';
import 'package:katya_ai_rechain_mesh/infrastructure/repositories/crypto_repository_impl.dart';
import 'package:katya_ai_rechain_mesh/infrastructure/repositories/ai_repository_impl.dart';
import 'package:katya_ai_rechain_mesh/infrastructure/services/mesh_service_impl.dart';
import 'package:katya_ai_rechain_mesh/infrastructure/services/crypto_service_impl.dart';
import 'package:katya_ai_rechain_mesh/infrastructure/services/ai_service_impl.dart';
import 'package:katya_ai_rechain_mesh/infrastructure/services/quantum_service_impl.dart';
import 'package:katya_ai_rechain_mesh/presentation/blocs/mesh_bloc.dart';
import 'package:katya_ai_rechain_mesh/presentation/blocs/crypto_bloc.dart';
import 'package:katya_ai_rechain_mesh/presentation/blocs/ai_bloc.dart';

/// Global service locator instance
final GetIt getIt = GetIt.instance;

/// Initialize dependency injection
Future<void> setupInjection() async {
  // Services
  getIt.registerLazySingleton<MeshService>(
    () => MeshServiceImpl(
      localPeerName: 'KatyaDevice',
      deviceType: 'mobile',
    ),
  );

  getIt.registerLazySingleton<CryptoService>(
    () => CryptoServiceImpl(),
  );

  getIt.registerLazySingleton<AIService>(
    () => AIServiceImpl(),
  );

  getIt.registerLazySingleton<QuantumService>(
    () => QuantumServiceImpl(),
  );

  // Repositories
  getIt.registerLazySingleton<MeshRepository>(
    () => MeshRepositoryImpl(getIt<MeshService>()),
  );

  getIt.registerLazySingleton<CryptoRepository>(
    () => CryptoRepositoryImpl(getIt<CryptoService>()),
  );

  getIt.registerLazySingleton<AIRepository>(
    () => AIRepositoryImpl(getIt<AIService>()),
  );

  // Use Cases
  getIt.registerLazySingleton<DiscoverPeersUseCase>(
    () => DiscoverPeersUseCase(getIt<MeshRepository>()),
  );

  getIt.registerLazySingleton<SendMessageUseCase>(
    () => SendMessageUseCase(getIt<MeshRepository>()),
  );

  getIt.registerLazySingleton<EncryptMessageUseCase>(
    () => EncryptMessageUseCase(getIt<CryptoRepository>()),
  );

  getIt.registerLazySingleton<ProcessAIRequestUseCase>(
    () => ProcessAIRequestUseCase(getIt<AIRepository>()),
  );

  // BLoCs
  getIt.registerFactory<MeshBloc>(
    () => MeshBloc(
      discoverPeersUseCase: getIt<DiscoverPeersUseCase>(),
      sendMessageUseCase: getIt<SendMessageUseCase>(),
      meshRepository: getIt<MeshRepository>(),
    ),
  );

  getIt.registerFactory<CryptoBloc>(
    () => CryptoBloc(
      encryptMessageUseCase: getIt<EncryptMessageUseCase>(),
      cryptoRepository: getIt<CryptoRepository>(),
    ),
  );

  getIt.registerFactory<AIBloc>(
    () => AIBloc(
      processAIRequestUseCase: getIt<ProcessAIRequestUseCase>(),
      aiRepository: getIt<AIRepository>(),
    ),
  );
}
