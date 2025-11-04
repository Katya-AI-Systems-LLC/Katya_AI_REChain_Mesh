import 'dart:async';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:katya_ai_rechain_mesh/core/domain/entities/ai_response.dart';
import 'package:katya_ai_rechain_mesh/core/domain/usecases/process_ai_request_usecase.dart';
import 'package:katya_ai_rechain_mesh/core/domain/repositories/ai_repository.dart';

part 'ai_event.dart';
part 'ai_state.dart';

/// BLoC for managing AI operations
class AIBloc extends Bloc<AIEvent, AIState> {
  final ProcessAIRequestUseCase _processAIRequestUseCase;
  final AIRepository _aiRepository;

  AIBloc({
    required ProcessAIRequestUseCase processAIRequestUseCase,
    required AIRepository aiRepository,
  })  : _processAIRequestUseCase = processAIRequestUseCase,
        _aiRepository = aiRepository,
        super(const AIState()) {
    on<InitializeAI>(_onInitializeAI);
    on<ProcessAIRequest>(_onProcessAIRequest);
    on<StreamAIRequest>(_onStreamAIRequest);
    on<ClassifyText>(_onClassifyText);
    on<DetectIntent>(_onDetectIntent);
    on<SuggestRoute>(_onSuggestRoute);
    on<SuggestMessages>(_onSuggestMessages);
    on<SpeechToText>(_onSpeechToText);
    on<AnalyzeSentiment>(_onAnalyzeSentiment);
    on<OptimizeRouting>(_onOptimizeRouting);
    on<RecommendPeers>(_onRecommendPeers);
    on<AnalyzeSecurity>(_onAnalyzeSecurity);
    on<ModerateContent>(_onModerateContent);
    on<UpdateFederatedModel>(_onUpdateFederatedModel);
    on<GetModelMetrics>(_onGetModelMetrics);
    on<ClearAIError>(_onClearAIError);
  }

  @override
  Future<void> close() async {
    await _aiRepository.dispose();
    return super.close();
  }

  Future<void> _onInitializeAI(
    InitializeAI event,
    Emitter<AIState> emit,
  ) async {
    emit(state.copyWith(status: AIStatus.initializing));

    try {
      await _aiRepository.initialize();
      emit(state.copyWith(
        status: AIStatus.initialized,
        isOnDeviceAvailable: _aiRepository.isOnDeviceAvailable,
        supportsFederatedLearning: _aiRepository.supportsFederatedLearning,
        supportedModels: _aiRepository.supportedModels,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AIStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onProcessAIRequest(
    ProcessAIRequest event,
    Emitter<AIState> emit,
  ) async {
    emit(state.copyWith(isProcessing: true));

    try {
      final result = await _processAIRequestUseCase.call(
        prompt: event.prompt,
        type: event.type,
        context: event.context,
        useFederatedLearning: event.useFederatedLearning,
      );

      result.fold(
        (response) => emit(state.copyWith(
          isProcessing: false,
          lastResponse: response,
        )),
        (error) => emit(state.copyWith(
          isProcessing: false,
          errorMessage: error,
        )),
      );
    } catch (e) {
      emit(state.copyWith(
        isProcessing: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onStreamAIRequest(
    StreamAIRequest event,
    Emitter<AIState> emit,
  ) async {
    emit(state.copyWith(isStreaming: true));

    try {
      await for (final response in _aiRepository.processRequestStream(
        prompt: event.prompt,
        type: event.type,
        context: event.context,
      )) {
        emit(state.copyWith(
          lastResponse: response,
          isStreaming: response.metadata?['partial'] != true,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isStreaming: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onClassifyText(
    ClassifyText event,
    Emitter<AIState> emit,
  ) async {
    emit(state.copyWith(isProcessing: true));

    try {
      final response = await _aiRepository.classifyText(
        text: event.text,
        categories: event.categories,
      );

      emit(state.copyWith(
        isProcessing: false,
        lastResponse: response,
      ));
    } catch (e) {
      emit(state.copyWith(
        isProcessing: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDetectIntent(
    DetectIntent event,
    Emitter<AIState> emit,
  ) async {
    emit(state.copyWith(isProcessing: true));

    try {
      final response = await _aiRepository.detectIntent(event.message);

      emit(state.copyWith(
        isProcessing: false,
        lastResponse: response,
      ));
    } catch (e) {
      emit(state.copyWith(
        isProcessing: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSuggestRoute(
    SuggestRoute event,
    Emitter<AIState> emit,
  ) async {
    emit(state.copyWith(isProcessing: true));

    try {
      final response = await _aiRepository.suggestRoute(
        sourcePeerId: event.sourcePeerId,
        targetPeerId: event.targetPeerId,
        availablePeers: event.availablePeers,
      );

      emit(state.copyWith(
        isProcessing: false,
        lastResponse: response,
      ));
    } catch (e) {
      emit(state.copyWith(
        isProcessing: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSuggestMessages(
    SuggestMessages event,
    Emitter<AIState> emit,
  ) async {
    emit(state.copyWith(isProcessing: true));

    try {
      final suggestions = await _aiRepository.suggestMessages(
        conversationContext: event.conversationContext,
        maxSuggestions: event.maxSuggestions,
      );

      emit(state.copyWith(
        isProcessing: false,
        messageSuggestions: suggestions,
      ));
    } catch (e) {
      emit(state.copyWith(
        isProcessing: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSpeechToText(
    SpeechToText event,
    Emitter<AIState> emit,
  ) async {
    emit(state.copyWith(isProcessing: true));

    try {
      final response = await _aiRepository.speechToText(event.audioData);

      emit(state.copyWith(
        isProcessing: false,
        lastResponse: response,
      ));
    } catch (e) {
      emit(state.copyWith(
        isProcessing: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAnalyzeSentiment(
    AnalyzeSentiment event,
    Emitter<AIState> emit,
  ) async {
    emit(state.copyWith(isProcessing: true));

    try {
      final response = await _aiRepository.analyzeSentiment(event.text);

      emit(state.copyWith(
        isProcessing: false,
        lastResponse: response,
      ));
    } catch (e) {
      emit(state.copyWith(
        isProcessing: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onOptimizeRouting(
    OptimizeRouting event,
    Emitter<AIState> emit,
  ) async {
    emit(state.copyWith(isProcessing: true));

    try {
      final response = await _aiRepository.optimizeRouting(
        networkTopology: event.networkTopology,
        activePeers: event.activePeers,
      );

      emit(state.copyWith(
        isProcessing: false,
        lastResponse: response,
      ));
    } catch (e) {
      emit(state.copyWith(
        isProcessing: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRecommendPeers(
    RecommendPeers event,
    Emitter<AIState> emit,
  ) async {
    emit(state.copyWith(isProcessing: true));

    try {
      final recommendations = await _aiRepository.recommendPeers(
        currentPeerId: event.currentPeerId,
        availablePeers: event.availablePeers,
        preferences: event.preferences,
      );

      emit(state.copyWith(
        isProcessing: false,
        peerRecommendations: recommendations,
      ));
    } catch (e) {
      emit(state.copyWith(
        isProcessing: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAnalyzeSecurity(
    AnalyzeSecurity event,
    Emitter<AIState> emit,
  ) async {
    emit(state.copyWith(isProcessing: true));

    try {
      final response = await _aiRepository.analyzeSecurity(event.message);

      emit(state.copyWith(
        isProcessing: false,
        lastResponse: response,
      ));
    } catch (e) {
      emit(state.copyWith(
        isProcessing: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onModerateContent(
    ModerateContent event,
    Emitter<AIState> emit,
  ) async {
    emit(state.copyWith(isProcessing: true));

    try {
      final response = await _aiRepository.moderateContent(event.content);

      emit(state.copyWith(
        isProcessing: false,
        lastResponse: response,
      ));
    } catch (e) {
      emit(state.copyWith(
        isProcessing: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateFederatedModel(
    UpdateFederatedModel event,
    Emitter<AIState> emit,
  ) async {
    emit(state.copyWith(isUpdatingModel: true));

    try {
      await _aiRepository.updateFederatedModel(
        trainingData: event.trainingData,
        modelType: event.modelType,
      );

      emit(state.copyWith(isUpdatingModel: false));
    } catch (e) {
      emit(state.copyWith(
        isUpdatingModel: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onGetModelMetrics(
    GetModelMetrics event,
    Emitter<AIState> emit,
  ) async {
    emit(state.copyWith(isLoadingMetrics: true));

    try {
      final metrics = await _aiRepository.getModelMetrics();

      emit(state.copyWith(
        isLoadingMetrics: false,
        modelMetrics: metrics,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingMetrics: false,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onClearAIError(
    ClearAIError event,
    Emitter<AIState> emit,
  ) {
    emit(state.clearError());
  }
}
