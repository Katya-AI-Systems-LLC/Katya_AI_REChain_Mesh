part of 'ai_bloc.dart';

/// Status of the AI system
enum AIStatus {
  initial,
  initializing,
  initialized,
  error,
}

/// State for the AI BLoC
class AIState extends Equatable {
  /// Current status of the AI system
  final AIStatus status;

  /// Last AI response
  final AIResponse? lastResponse;

  /// Message suggestions
  final List<String> messageSuggestions;

  /// Peer recommendations
  final List<String> peerRecommendations;

  /// Model metrics
  final Map<String, dynamic> modelMetrics;

  /// Whether on-device AI is available
  final bool isOnDeviceAvailable;

  /// Whether federated learning is supported
  final bool supportsFederatedLearning;

  /// Supported AI models
  final List<String> supportedModels;

  /// Whether processing an AI request
  final bool isProcessing;

  /// Whether streaming AI response
  final bool isStreaming;

  /// Whether updating federated model
  final bool isUpdatingModel;

  /// Whether loading model metrics
  final bool isLoadingMetrics;

  /// Error message if any
  final String? errorMessage;

  const AIState({
    this.status = AIStatus.initial,
    this.lastResponse,
    this.messageSuggestions = const [],
    this.peerRecommendations = const [],
    this.modelMetrics = const {},
    this.isOnDeviceAvailable = false,
    this.supportsFederatedLearning = false,
    this.supportedModels = const [],
    this.isProcessing = false,
    this.isStreaming = false,
    this.isUpdatingModel = false,
    this.isLoadingMetrics = false,
    this.errorMessage,
  });

  /// Create a copy with updated fields
  AIState copyWith({
    AIStatus? status,
    AIResponse? lastResponse,
    List<String>? messageSuggestions,
    List<String>? peerRecommendations,
    Map<String, dynamic>? modelMetrics,
    bool? isOnDeviceAvailable,
    bool? supportsFederatedLearning,
    List<String>? supportedModels,
    bool? isProcessing,
    bool? isStreaming,
    bool? isUpdatingModel,
    bool? isLoadingMetrics,
    String? errorMessage,
  }) {
    return AIState(
      status: status ?? this.status,
      lastResponse: lastResponse ?? this.lastResponse,
      messageSuggestions: messageSuggestions ?? this.messageSuggestions,
      peerRecommendations: peerRecommendations ?? this.peerRecommendations,
      modelMetrics: modelMetrics ?? this.modelMetrics,
      isOnDeviceAvailable: isOnDeviceAvailable ?? this.isOnDeviceAvailable,
      supportsFederatedLearning: supportsFederatedLearning ?? this.supportsFederatedLearning,
      supportedModels: supportedModels ?? this.supportedModels,
      isProcessing: isProcessing ?? this.isProcessing,
      isStreaming: isStreaming ?? this.isStreaming,
      isUpdatingModel: isUpdatingModel ?? this.isUpdatingModel,
      isLoadingMetrics: isLoadingMetrics ?? this.isLoadingMetrics,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Check if the AI system is initialized
  bool get isInitialized => status == AIStatus.initialized;

  /// Check if there are any errors
  bool get hasError => errorMessage != null;

  /// Check if any operation is in progress
  bool get isOperationInProgress =>
      isProcessing ||
      isStreaming ||
      isUpdatingModel ||
      isLoadingMetrics;

  /// Get the confidence of the last response
  double get lastResponseConfidence => lastResponse?.confidence ?? 0.0;

  /// Check if the last response is confident
  bool get isLastResponseConfident => lastResponse?.isConfident ?? false;

  /// Get the processing time of the last response
  int get lastResponseProcessingTime => lastResponse?.processingTimeMs ?? 0;

  /// Clear error message
  AIState clearError() => copyWith(errorMessage: null);

  @override
  List<Object?> get props => [
    status,
    lastResponse,
    messageSuggestions,
    peerRecommendations,
    modelMetrics,
    isOnDeviceAvailable,
    supportsFederatedLearning,
    supportedModels,
    isProcessing,
    isStreaming,
    isUpdatingModel,
    isLoadingMetrics,
    errorMessage,
  ];

  @override
  String toString() {
    return 'AIState('
        'status: $status, '
        'hasResponse: ${lastResponse != null}, '
        'suggestions: ${messageSuggestions.length}, '
        'recommendations: ${peerRecommendations.length}, '
        'isOnDeviceAvailable: $isOnDeviceAvailable, '
        'isOperationInProgress: $isOperationInProgress, '
        'error: $errorMessage'
        ')';
  }
}
