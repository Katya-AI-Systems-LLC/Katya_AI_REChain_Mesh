
/// Base class for all AI-related exceptions
abstract class AIException implements Exception {
  /// A message describing the error
  final String message;

  /// The underlying exception that caused this error
  final dynamic error;

  /// Stack trace associated with the error
  final StackTrace? stackTrace;

  const AIException({
    required this.message,
    this.error,
    this.stackTrace,
  });

  @override
  String toString() =>
      'AIException: $message${error != null ? '\nError: $error' : ''}';
}

/// Thrown when there's an error initializing the AI service
class AIInitializationException extends AIException {
  const AIInitializationException({
    super.message = 'Failed to initialize AI service',
    super.error,
    super.stackTrace,
  });
}

/// Thrown when there's an error loading a model
class ModelLoadException extends AIException {
  /// The ID of the model that failed to load
  final String modelId;

  const ModelLoadException({
    required this.modelId,
    String message = 'Failed to load model',
    super.error,
    super.stackTrace,
  }) : super(message: '$message (Model: $modelId)');
}

/// Thrown when trying to use a model that hasn't been loaded
class ModelNotLoadedException extends AIException {
  const ModelNotLoadedException(
      [String message = 'No AI model is currently loaded'])
      : super(message: message);
}

/// Thrown when there's an error during model inference
class ModelInferenceException extends AIException {
  /// The ID of the model that caused the error
  final String modelId;

  const ModelInferenceException({
    required this.modelId,
    String message = 'Error during model inference',
    super.error,
    super.stackTrace,
  }) : super(message: '$message (Model: $modelId)');
}

/// Thrown when there's an error processing AI input/output
class AIProcessingException extends AIException {
  const AIProcessingException({
    super.message = 'Error processing AI input/output',
    super.error,
    super.stackTrace,
  });
}

/// Thrown when a requested model is not found
class ModelNotFoundException extends AIException {
  /// The ID of the model that was not found
  final String modelId;

  const ModelNotFoundException(this.modelId, {String? message})
      : super(
          message: message ?? 'Model not found: $modelId',
        );
}

/// Thrown when a model download fails
class ModelDownloadException extends AIException {
  /// The ID of the model that failed to download
  final String modelId;

  const ModelDownloadException({
    required this.modelId,
    String message = 'Failed to download model',
    super.error,
    super.stackTrace,
  }) : super(message: '$message (Model: $modelId)');
}

/// Thrown when a model is not compatible with the current platform
class ModelIncompatibleException extends AIException {
  /// The ID of the incompatible model
  final String modelId;

  /// The required platform
  final String requiredPlatform;

  /// The current platform
  final String currentPlatform;

  const ModelIncompatibleException({
    required this.modelId,
    required this.requiredPlatform,
    required this.currentPlatform,
    String? message,
  }) : super(
          message: message ??
              'Model $modelId requires $requiredPlatform but current platform is $currentPlatform',
        );
}

/// Thrown when the device doesn't have enough resources to run a model
class InsufficientResourcesException extends AIException {
  /// The ID of the model that requires more resources
  final String modelId;

  /// The type of resource that's insufficient (e.g., 'RAM', 'storage', 'compute')
  final String resourceType;

  /// The required amount of the resource
  final int requiredAmount;

  /// The available amount of the resource
  final int availableAmount;

  const InsufficientResourcesException({
    required this.modelId,
    required this.resourceType,
    required this.requiredAmount,
    required this.availableAmount,
    String? message,
  }) : super(
          message: message ??
              'Insufficient $resourceType for model $modelId (required: $requiredAmount, available: $availableAmount)',
        );
}

/// Thrown when a model's input is invalid
class InvalidInputException extends AIException {
  /// The ID of the model that received invalid input
  final String modelId;

  /// Description of what made the input invalid
  final String reason;

  const InvalidInputException({
    required this.modelId,
    required this.reason,
    String? message,
  }) : super(
          message: message ?? 'Invalid input for model $modelId: $reason',
        );
}

/// Thrown when a model's output is invalid or unexpected
class InvalidOutputException extends AIException {
  /// The ID of the model that produced invalid output
  final String modelId;

  /// Description of what made the output invalid
  final String reason;

  const InvalidOutputException({
    required this.modelId,
    required this.reason,
    String? message,
  }) : super(
          message: message ?? 'Invalid output from model $modelId: $reason',
        );
}
