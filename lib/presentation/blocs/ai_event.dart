part of 'ai_bloc.dart';

/// Base class for AI-related events
abstract class AIEvent extends Equatable {
  const AIEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize the AI system
class InitializeAI extends AIEvent {
  const InitializeAI();
}

/// Event to process an AI request
class ProcessAIRequest extends AIEvent {
  final String prompt;
  final AIRequestType type;
  final Map<String, dynamic>? context;
  final bool useFederatedLearning;

  const ProcessAIRequest({
    required this.prompt,
    required this.type,
    this.context,
    this.useFederatedLearning = false,
  });

  @override
  List<Object?> get props => [prompt, type, context, useFederatedLearning];
}

/// Event to stream AI request processing
class StreamAIRequest extends AIEvent {
  final String prompt;
  final AIRequestType type;
  final Map<String, dynamic>? context;

  const StreamAIRequest({
    required this.prompt,
    required this.type,
    this.context,
  });

  @override
  List<Object?> get props => [prompt, type, context];
}

/// Event to classify text
class ClassifyText extends AIEvent {
  final String text;
  final List<String>? categories;

  const ClassifyText({
    required this.text,
    this.categories,
  });

  @override
  List<Object?> get props => [text, categories];
}

/// Event to detect intent
class DetectIntent extends AIEvent {
  final String message;

  const DetectIntent(this.message);

  @override
  List<Object?> get props => [message];
}

/// Event to suggest routing
class SuggestRoute extends AIEvent {
  final String sourcePeerId;
  final String targetPeerId;
  final List<String> availablePeers;

  const SuggestRoute({
    required this.sourcePeerId,
    required this.targetPeerId,
    required this.availablePeers,
  });

  @override
  List<Object?> get props => [sourcePeerId, targetPeerId, availablePeers];
}

/// Event to suggest messages
class SuggestMessages extends AIEvent {
  final String conversationContext;
  final int maxSuggestions;

  const SuggestMessages({
    required this.conversationContext,
    this.maxSuggestions = 3,
  });

  @override
  List<Object?> get props => [conversationContext, maxSuggestions];
}

/// Event to convert speech to text
class SpeechToText extends AIEvent {
  final Uint8List audioData;

  const SpeechToText(this.audioData);

  @override
  List<Object?> get props => [audioData];
}

/// Event to analyze sentiment
class AnalyzeSentiment extends AIEvent {
  final String text;

  const AnalyzeSentiment(this.text);

  @override
  List<Object?> get props => [text];
}

/// Event to optimize routing
class OptimizeRouting extends AIEvent {
  final Map<String, dynamic> networkTopology;
  final List<String> activePeers;

  const OptimizeRouting({
    required this.networkTopology,
    required this.activePeers,
  });

  @override
  List<Object?> get props => [networkTopology, activePeers];
}

/// Event to recommend peers
class RecommendPeers extends AIEvent {
  final String currentPeerId;
  final List<String> availablePeers;
  final Map<String, dynamic>? preferences;

  const RecommendPeers({
    required this.currentPeerId,
    required this.availablePeers,
    this.preferences,
  });

  @override
  List<Object?> get props => [currentPeerId, availablePeers, preferences];
}

/// Event to analyze security
class AnalyzeSecurity extends AIEvent {
  final String message;

  const AnalyzeSecurity(this.message);

  @override
  List<Object?> get props => [message];
}

/// Event to moderate content
class ModerateContent extends AIEvent {
  final String content;

  const ModerateContent(this.content);

  @override
  List<Object?> get props => [content];
}

/// Event to update federated model
class UpdateFederatedModel extends AIEvent {
  final Map<String, dynamic> trainingData;
  final String modelType;

  const UpdateFederatedModel({
    required this.trainingData,
    required this.modelType,
  });

  @override
  List<Object?> get props => [trainingData, modelType];
}

/// Event to get model metrics
class GetModelMetrics extends AIEvent {
  const GetModelMetrics();
}

/// Event to clear AI error
class ClearAIError extends AIEvent {
  const ClearAIError();
}
