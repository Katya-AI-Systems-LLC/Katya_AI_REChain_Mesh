import 'package:equatable/equatable.dart';

/// Represents an AI processing response
class AIResponse extends Equatable {
  /// Unique response ID
  final String id;

  /// Type of AI request that was processed
  final AIRequestType type;

  /// The original prompt/input
  final String prompt;

  /// The AI-generated response
  final String response;

  /// Confidence score (0.0 to 1.0)
  final double confidence;

  /// Processing time in milliseconds
  final int processingTimeMs;

  /// Whether this was processed on-device
  final bool isOnDevice;

  /// Whether federated learning was used
  final bool usedFederatedLearning;

  /// Additional metadata from the AI model
  final Map<String, dynamic>? metadata;

  /// Timestamp when the response was generated
  final DateTime timestamp;

  const AIResponse({
    required this.id,
    required this.type,
    required this.prompt,
    required this.response,
    required this.confidence,
    required this.processingTimeMs,
    this.isOnDevice = true,
    this.usedFederatedLearning = false,
    this.metadata,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Create an AIResponse from JSON
  factory AIResponse.fromJson(Map<String, dynamic> json) {
    return AIResponse(
      id: json['id'] as String,
      type: AIRequestType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AIRequestType.textClassification,
      ),
      prompt: json['prompt'] as String,
      response: json['response'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      processingTimeMs: json['processing_time_ms'] as int,
      isOnDevice: json['is_on_device'] as bool? ?? true,
      usedFederatedLearning: json['used_federated_learning'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'prompt': prompt,
      'response': response,
      'confidence': confidence,
      'processing_time_ms': processingTimeMs,
      'is_on_device': isOnDevice,
      'used_federated_learning': usedFederatedLearning,
      if (metadata != null) 'metadata': metadata,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  AIResponse copyWith({
    String? id,
    AIRequestType? type,
    String? prompt,
    String? response,
    double? confidence,
    int? processingTimeMs,
    bool? isOnDevice,
    bool? usedFederatedLearning,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
  }) {
    return AIResponse(
      id: id ?? this.id,
      type: type ?? this.type,
      prompt: prompt ?? this.prompt,
      response: response ?? this.response,
      confidence: confidence ?? this.confidence,
      processingTimeMs: processingTimeMs ?? this.processingTimeMs,
      isOnDevice: isOnDevice ?? this.isOnDevice,
      usedFederatedLearning: usedFederatedLearning ?? this.usedFederatedLearning,
      metadata: metadata ?? this.metadata,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Check if the response is confident enough
  bool get isConfident => confidence >= 0.8;

  /// Get processing time as Duration
  Duration get processingTime => Duration(milliseconds: processingTimeMs);

  @override
  List<Object?> get props => [
        id,
        type,
        prompt,
        response,
        confidence,
        processingTimeMs,
        isOnDevice,
        usedFederatedLearning,
        metadata,
        timestamp,
      ];
}

/// Types of AI requests supported
enum AIRequestType {
  textClassification,
  intentDetection,
  smartRouting,
  messageSuggestion,
  voiceToText,
  sentimentAnalysis,
  routeOptimization,
  peerRecommendation,
  securityAnalysis,
  contentModeration,
}
