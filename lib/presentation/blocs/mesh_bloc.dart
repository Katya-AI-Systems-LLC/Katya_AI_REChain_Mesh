import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:katya_ai_rechain_mesh/core/domain/entities/peer.dart';
import 'package:katya_ai_rechain_mesh/core/domain/entities/message.dart';
import 'package:katya_ai_rechain_mesh/core/domain/usecases/discover_peers_usecase.dart';
import 'package:katya_ai_rechain_mesh/core/domain/usecases/send_message_usecase.dart';
import 'package:katya_ai_rechain_mesh/core/domain/repositories/mesh_repository.dart';

part 'mesh_event.dart';
part 'mesh_state.dart';

/// BLoC for managing mesh networking state
class MeshBloc extends Bloc<MeshEvent, MeshState> {
  final DiscoverPeersUseCase _discoverPeersUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final MeshRepository _meshRepository;

  StreamSubscription<List<Peer>>? _peersSubscription;
  StreamSubscription<Message>? _messageSubscription;
  StreamSubscription<MeshConnectionState>? _connectionSubscription;

  MeshBloc({
    required DiscoverPeersUseCase discoverPeersUseCase,
    required SendMessageUseCase sendMessageUseCase,
    required MeshRepository meshRepository,
  })  : _discoverPeersUseCase = discoverPeersUseCase,
        _sendMessageUseCase = sendMessageUseCase,
        _meshRepository = meshRepository,
        super(const MeshState()) {
    on<InitializeMesh>(_onInitializeMesh);
    on<StartPeerDiscovery>(_onStartPeerDiscovery);
    on<StopPeerDiscovery>(_onStopPeerDiscovery);
    on<ConnectToPeer>(_onConnectToPeer);
    on<DisconnectFromPeer>(_onDisconnectFromPeer);
    on<SendMessageEvent>(_onSendMessage);
    on<BroadcastMessageEvent>(_onBroadcastMessage);
    on<_PeersUpdated>(_onPeersUpdated);
    on<_MessageReceived>(_onMessageReceived);
    on<_ConnectionStateChanged>(_onConnectionStateChanged);
  }

  @override
  Future<void> close() async {
    await _peersSubscription?.cancel();
    await _messageSubscription?.cancel();
    await _connectionSubscription?.cancel();
    await _meshRepository.dispose();
    return super.close();
  }

  Future<void> _onInitializeMesh(
    InitializeMesh event,
    Emitter<MeshState> emit,
  ) async {
    emit(state.copyWith(status: MeshStatus.initializing));

    try {
      await _meshRepository.initialize();

      // Set up stream subscriptions
      _peersSubscription = _meshRepository
          .discoverPeers()
          .listen((peers) => add(_PeersUpdated(peers)));

      _messageSubscription = _meshRepository.messageStream
          .listen((message) => add(_MessageReceived(message)));

      _connectionSubscription = _meshRepository.connectionStateStream
          .listen((connectionState) => add(_ConnectionStateChanged(connectionState)));

      emit(state.copyWith(
        status: MeshStatus.initialized,
        localPeerId: _meshRepository.localPeerId,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MeshStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onStartPeerDiscovery(
    StartPeerDiscovery event,
    Emitter<MeshState> emit,
  ) async {
    emit(state.copyWith(isDiscovering: true));

    try {
      final result = await _discoverPeersUseCase.call(
        timeout: event.timeout,
        includeSignalStrength: event.includeSignalStrength,
      );

      result.fold(
        (peers) => emit(state.copyWith(
          discoveredPeers: peers,
          isDiscovering: false,
        )),
        (error) => emit(state.copyWith(
          errorMessage: error,
          isDiscovering: false,
        )),
      );
    } catch (e) {
      emit(state.copyWith(
        errorMessage: e.toString(),
        isDiscovering: false,
      ));
    }
  }

  Future<void> _onStopPeerDiscovery(
    StopPeerDiscovery event,
    Emitter<MeshState> emit,
  ) async {
    await _meshRepository.stopDiscovery();
    emit(state.copyWith(isDiscovering: false));
  }

  Future<void> _onConnectToPeer(
    ConnectToPeer event,
    Emitter<MeshState> emit,
  ) async {
    emit(state.copyWith(isConnecting: true));

    try {
      await _meshRepository.connect(event.peerId);
      emit(state.copyWith(isConnecting: false));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: e.toString(),
        isConnecting: false,
      ));
    }
  }

  Future<void> _onDisconnectFromPeer(
    DisconnectFromPeer event,
    Emitter<MeshState> emit,
  ) async {
    try {
      await _meshRepository.disconnect(event.peerId);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<MeshState> emit,
  ) async {
    try {
      final result = await _sendMessageUseCase.call(
        message: event.message,
        useQuantumChannel: event.useQuantumChannel,
        maxHops: event.maxHops,
      );

      result.fold(
        (_) => {}, // Success - no action needed
        (error) => emit(state.copyWith(errorMessage: error)),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onBroadcastMessage(
    BroadcastMessageEvent event,
    Emitter<MeshState> emit,
  ) async {
    try {
      await _meshRepository.broadcastMessage(event.message);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  void _onPeersUpdated(_PeersUpdated event, Emitter<MeshState> emit) {
    emit(state.copyWith(discoveredPeers: event.peers));
  }

  void _onMessageReceived(_MessageReceived event, Emitter<MeshState> emit) {
    final updatedMessages = List<Message>.from(state.receivedMessages)
      ..add(event.message);

    emit(state.copyWith(receivedMessages: updatedMessages));
  }

  void _onConnectionStateChanged(
    _ConnectionStateChanged event,
    Emitter<MeshState> emit,
  ) {
    emit(state.copyWith(connectionState: event.connectionState));
  }
}
