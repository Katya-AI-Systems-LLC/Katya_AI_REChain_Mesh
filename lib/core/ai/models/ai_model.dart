import 'package:equatable/equatable.dart';

/// Represents an AI model that can be loaded and used for inference.
class AIModel extends Equatable {
  /// Unique identifier for the model
  final String id;
  
  /// Display name of the model
  final String name;
  
  /// Description of what the model does
  final String description;
  
  /// Version of the model
  final String version;
  
  /// Size of the model in bytes
  final int size;
  
  /// Whether the model is designed to run on device
  final bool isOnDevice;
  
  /// List of input types the model accepts (e.g., 'text', 'image', 'audio')
  final List<String> inputTypes;
  
  /// List of output types the model produces
  final List<String> outputTypes;
  
  /// Path to the model file (local or remote)
  final String modelPath;
  
  /// Whether the model is currently downloaded and available locally
  final bool isDownloaded;
  
  /// Required framework (e.g., 'tflite', 'pytorch', 'onnx')
  final String framework;
  
  /// License information for the model
  final String? license;
  
  /// Accuracy metrics if available
  final Map<String, dynamic>? metrics;
  
  /// Any additional metadata
  final Map<String, dynamic>? metadata;

  const AIModel({
    required this.id,
    required this.name,
    required this.description,
    required this.version,
    required this.size,
    required this.isOnDevice,
    required this.inputTypes,
    required this.outputTypes,
    required this.modelPath,
    required this.isDownloaded,
    required this.framework,
    this.license,
    this.metrics,
    this.metadata,
  });

  /// Creates a copy of this model with updated fields
  AIModel copyWith({
    String? id,
    String? name,
    String? description,
    String? version,
    int? size,
    bool? isOnDevice,
    List<String>? inputTypes,
    List<String>? outputTypes,
    String? modelPath,
    bool? isDownloaded,
    String? framework,
    String? license,
    Map<String, dynamic>? metrics,
    Map<String, dynamic>? metadata,
  }) {
    return AIModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      version: version ?? this.version,
      size: size ?? this.size,
      isOnDevice: isOnDevice ?? this.isOnDevice,
      inputTypes: inputTypes ?? this.inputTypes,
      outputTypes: outputTypes ?? this.outputTypes,
      modelPath: modelPath ?? this.modelPath,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      framework: framework ?? this.framework,
      license: license ?? this.license,
      metrics: metrics ?? this.metrics,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Creates a model from JSON
  factory AIModel.fromJson(Map<String, dynamic> json) {
    return AIModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      version: json['version'] as String? ?? '1.0.0',
      size: json['size'] as int? ?? 0,
      isOnDevice: json['isOnDevice'] as bool? ?? true,
      inputTypes: List<String>.from(json['inputTypes'] as List? ?? []),
      outputTypes: List<String>.from(json['outputTypes'] as List? ?? []),
      modelPath: json['modelPath'] as String,
      isDownloaded: json['isDownloaded'] as bool? ?? false,
      framework: json['framework'] as String? ?? 'tflite',
      license: json['license'] as String?,
      metrics: json['metrics'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Converts the model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'version': version,
      'size': size,
      'isOnDevice': isOnDevice,
      'inputTypes': inputTypes,
      'outputTypes': outputTypes,
      'modelPath': modelPath,
      'isDownloaded': isDownloaded,
      'framework': framework,
      if (license != null) 'license': license,
      if (metrics != null) 'metrics': metrics,
      if (metadata != null) 'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        version,
        modelPath,
        isDownloaded,
      ];

  @override
  bool get stringify => true;
}

/// Default AI models that come pre-configured with the app
class DefaultAIModels {
  // Text generation model
  static final textGeneration = AIModel(
    id: 'text-generation-001',
    name: 'Text Generation',
    description: 'Generates human-like text based on input prompts',
    version: '1.0.0',
    size: 500000000, // 500MB
    isOnDevice: true,
    inputTypes: ['text'],
    outputTypes: ['text'],
    modelPath: 'assets/models/text_generation.tflite',
    isDownloaded: false,
    framework: 'tflite',
    license: 'Apache 2.0',
  );

  // Image classification model
  static final imageClassification = AIModel(
    id: 'image-classification-001',
    name: 'Image Classification',
    description: 'Classifies images into predefined categories',
    version: '1.0.0',
    size: 25000000, // 25MB
    isOnDevice: true,
    inputTypes: ['image'],
    outputTypes: ['text', 'confidence'],
    modelPath: 'assets/models/image_classification.tflite',
    isDownloaded: false,
    framework: 'tflite',
    license: 'MIT',
  );

  // Sentiment analysis model
  static final sentimentAnalysis = AIModel(
    id: 'sentiment-analysis-001',
    name: 'Sentiment Analysis',
    description: 'Analyzes text sentiment (positive, negative, neutral)',
    version: '1.0.0',
    size: 5000000, // 5MB
    isOnDevice: true,
    inputTypes: ['text'],
    outputTypes: ['sentiment', 'confidence'],
    modelPath: 'assets/models/sentiment_analysis.tflite',
    isDownloaded: false,
    framework: 'tflite',
    license: 'Apache 2.0',
  );

  // Get all default models
  static List<AIModel> get all => [
        textGeneration,
        imageClassification,
        sentimentAnalysis,
      ];
}
