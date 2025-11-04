/// Base class for all services
abstract class BaseService {
  /// Service name for logging and debugging
  String get serviceName;
  
  /// Whether the service has been initialized
  bool get isInitialized;
  
  /// Initializes the service
  /// Should be called before using the service
  Future<void> initialize();
  
  /// Disposes of any resources used by the service
  /// Should be called when the service is no longer needed
  Future<void> dispose();
}

/// A service that can be started and stopped
abstract class LifecycleService extends BaseService {
  /// Whether the service is currently running
  bool get isRunning;
  
  /// Starts the service
  /// Should be called after initialize()
  Future<void> start();
  
  /// Stops the service
  /// Can be restarted with start()
  Future<void> stop();
}

/// A service that can be observed for state changes
abstract class ObservableService<T> {
  /// Stream of state changes
  Stream<T> get stateChanges;
  
  /// Current state of the service
  T get currentState;
}

/// A service that can handle errors
abstract class ErrorHandlingService {
  /// Stream of errors
  Stream<ServiceError> get errors;
  
  /// Handles an error
  void handleError(ServiceError error);
}

/// Represents an error that occurred in a service
class ServiceError {
  /// Error message
  final String message;
  
  /// Stack trace if available
  final StackTrace? stackTrace;
  
  /// Timestamp when the error occurred
  final DateTime timestamp;
  
  /// Severity of the error
  final ErrorSeverity severity;
  
  /// Optional error code
  final String? code;
  
  /// Optional additional data
  final Map<String, dynamic>? data;

  const ServiceError({
    required this.message,
    this.stackTrace,
    DateTime? timestamp,
    this.severity = ErrorSeverity.error,
    this.code,
    this.data,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Creates a copy with updated fields
  ServiceError copyWith({
    String? message,
    StackTrace? stackTrace,
    DateTime? timestamp,
    ErrorSeverity? severity,
    String? code,
    Map<String, dynamic>? data,
  }) {
    return ServiceError(
      message: message ?? this.message,
      stackTrace: stackTrace ?? this.stackTrace,
      timestamp: timestamp ?? this.timestamp,
      severity: severity ?? this.severity,
      code: code ?? this.code,
      data: data ?? this.data,
    );
  }
  
  @override
  String toString() {
    return 'ServiceError(' 
        'message: $message, '
        'code: $code, '
        'severity: $severity, '
        'at: $timestamp'
        ')';
  }
}

/// Severity levels for service errors
enum ErrorSeverity {
  /// Debug information
  debug,
  
  /// Informational message
  info,
  
  /// Warning message
  warning,
  
  /// Error that doesn't prevent the service from functioning
  error,
  
  /// Critical error that prevents the service from functioning
  critical,
}
