import 'package:equatable/equatable.dart';

/// Represents the result of an operation that can succeed or fail
class Result<T> extends Equatable {
  /// The successful result value (null if failed)
  final T? value;

  /// The error message (null if successful)
  final String? error;

  /// Whether the operation was successful
  bool get isSuccess => error == null;

  /// Whether the operation failed
  bool get isFailure => error != null;

  const Result._(this.value, this.error);

  /// Create a successful result
  const Result.success(T value) : this._(value, null);

  /// Create a failed result
  const Result.failure(String error) : this._(null, error);

  /// Get the successful value or throw an exception
  T get requireValue {
    if (error != null) {
      throw ResultException(error!);
    }
    return value as T;
  }

  /// Get the error message or throw an exception
  String get requireError {
    if (value != null) {
      throw StateError('Result is successful, no error available');
    }
    return error!;
  }

  /// Transform the successful value using a mapper function
  Result<U> map<U>(U Function(T) mapper) {
    if (isSuccess) {
      return Result.success(mapper(value as T));
    } else {
      return Result.failure(error!);
    }
  }

  /// Transform the successful value or return a default on failure
  Result<U> mapOr<U>(U Function(T) mapper, U defaultValue) {
    if (isSuccess) {
      return Result.success(mapper(value as T));
    } else {
      return Result.success(defaultValue);
    }
  }

  /// Transform the error using a mapper function
  Result<T> mapError(String Function(String) mapper) {
    if (isFailure) {
      return Result.failure(mapper(error!));
    } else {
      return this;
    }
  }

  /// Execute a function on success
  Result<T> onSuccess(void Function(T) action) {
    if (isSuccess) {
      action(value as T);
    }
    return this;
  }

  /// Execute a function on failure
  Result<T> onFailure(void Function(String) action) {
    if (isFailure) {
      action(error!);
    }
    return this;
  }

  /// Convert to another result type on success
  Result<U> flatMap<U>(Result<U> Function(T) mapper) {
    if (isSuccess) {
      return mapper(value as T);
    } else {
      return Result.failure(error!);
    }
  }

  /// Get the value or a default value
  T getOrDefault(T defaultValue) {
    return isSuccess ? value as T : defaultValue;
  }

  /// Get the value or null
  T? getOrNull() {
    return value;
  }

  @override
  List<Object?> get props => [value, error];

  @override
  String toString() {
    if (isSuccess) {
      return 'Result.success($value)';
    } else {
      return 'Result.failure($error)';
    }
  }
}

/// Exception thrown when requiring a value from a failed result
class ResultException implements Exception {
  final String message;

  const ResultException(this.message);

  @override
  String toString() => 'ResultException: $message';
}

/// Extension methods for Result
extension ResultExtensions<T> on Result<T> {
  /// Convert to a Future for async operations
  Future<Result<T>> asFuture() async => this;

  /// Fold the result into a single value
  U fold<U>(U Function(T) onSuccess, U Function(String) onFailure) {
    if (isSuccess) {
      return onSuccess(value as T);
    } else {
      return onFailure(error!);
    }
  }
}

/// Utility functions for working with Results
class ResultUtils {
  /// Combine multiple results into a single result
  static Result<List<T>> combine<T>(List<Result<T>> results) {
    final values = <T>[];
    final errors = <String>[];

    for (final result in results) {
      if (result.isSuccess) {
        values.add(result.value as T);
      } else {
        errors.add(result.error!);
      }
    }

    if (errors.isEmpty) {
      return Result.success(values);
    } else {
      return Result.failure(errors.join('; '));
    }
  }

  /// Execute an async operation and wrap the result
  static Future<Result<T>> wrapAsync<T>(Future<T> Function() operation) async {
    try {
      final value = await operation();
      return Result.success(value);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// Execute a sync operation and wrap the result
  static Result<T> wrapSync<T>(T Function() operation) {
    try {
      final value = operation();
      return Result.success(value);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}
