class FirebaseInitializationException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  FirebaseInitializationException({
    required this.message,
    this.stackTrace,
  });

  @override
  String toString() => 'FirebaseInitializationException: $message';
}

class FirebaseAuthException implements Exception {
  final String message;
  final String? code;
  final String? email;
  final StackTrace? stackTrace;

  FirebaseAuthException({
    required this.message,
    this.code,
    this.email,
    this.stackTrace,
  });

  @override
  String toString() => 'FirebaseAuthException: $message (${code ?? 'no code'})';
}

class FirestoreException implements Exception {
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  FirestoreException({
    required this.message,
    this.code,
    this.stackTrace,
  });

  @override
  String toString() => 'FirestoreException: $message (${code ?? 'no code'})';
}

class StorageException implements Exception {
  final String message;
  final String? code;
  final String? path;
  final StackTrace? stackTrace;

  StorageException({
    required this.message,
    this.code,
    this.path,
    this.stackTrace,
  });

  @override
  String toString() => 'StorageException: $message (${code ?? 'no code'})';
}
