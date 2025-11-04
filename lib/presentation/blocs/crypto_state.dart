part of 'crypto_bloc.dart';

/// Status of the crypto system
enum CryptoStatus {
  initial,
  initializing,
  initialized,
  error,
}

/// State for the crypto BLoC
class CryptoState extends Equatable {
  /// Current status of the crypto system
  final CryptoStatus status;

  /// Current key pair
  final KeyPair? currentKeyPair;

  /// Current user public key
  final String? currentUserPublicKey;

  /// Last encrypted data
  final Uint8List? lastEncryptedData;

  /// Last decrypted data
  final Uint8List? lastDecryptedData;

  /// Last signature
  final Uint8List? lastSignature;

  /// Last verification result
  final bool? lastVerificationResult;

  /// Last exported keys
  final String? lastExportedKeys;

  /// Whether generating keys
  final bool isGeneratingKeys;

  /// Whether encrypting
  final bool isEncrypting;

  /// Whether decrypting
  final bool isDecrypting;

  /// Whether signing
  final bool isSigning;

  /// Whether verifying
  final bool isVerifying;

  /// Whether exporting
  final bool isExporting;

  /// Whether importing
  final bool isImporting;

  /// Error message if any
  final String? errorMessage;

  const CryptoState({
    this.status = CryptoStatus.initial,
    this.currentKeyPair,
    this.currentUserPublicKey,
    this.lastEncryptedData,
    this.lastDecryptedData,
    this.lastSignature,
    this.lastVerificationResult,
    this.lastExportedKeys,
    this.isGeneratingKeys = false,
    this.isEncrypting = false,
    this.isDecrypting = false,
    this.isSigning = false,
    this.isVerifying = false,
    this.isExporting = false,
    this.isImporting = false,
    this.errorMessage,
  });

  /// Create a copy with updated fields
  CryptoState copyWith({
    CryptoStatus? status,
    KeyPair? currentKeyPair,
    String? currentUserPublicKey,
    Uint8List? lastEncryptedData,
    Uint8List? lastDecryptedData,
    Uint8List? lastSignature,
    bool? lastVerificationResult,
    String? lastExportedKeys,
    bool? isGeneratingKeys,
    bool? isEncrypting,
    bool? isDecrypting,
    bool? isSigning,
    bool? isVerifying,
    bool? isExporting,
    bool? isImporting,
    String? errorMessage,
  }) {
    return CryptoState(
      status: status ?? this.status,
      currentKeyPair: currentKeyPair ?? this.currentKeyPair,
      currentUserPublicKey: currentUserPublicKey ?? this.currentUserPublicKey,
      lastEncryptedData: lastEncryptedData ?? this.lastEncryptedData,
      lastDecryptedData: lastDecryptedData ?? this.lastDecryptedData,
      lastSignature: lastSignature ?? this.lastSignature,
      lastVerificationResult: lastVerificationResult ?? this.lastVerificationResult,
      lastExportedKeys: lastExportedKeys ?? this.lastExportedKeys,
      isGeneratingKeys: isGeneratingKeys ?? this.isGeneratingKeys,
      isEncrypting: isEncrypting ?? this.isEncrypting,
      isDecrypting: isDecrypting ?? this.isDecrypting,
      isSigning: isSigning ?? this.isSigning,
      isVerifying: isVerifying ?? this.isVerifying,
      isExporting: isExporting ?? this.isExporting,
      isImporting: isImporting ?? this.isImporting,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Check if the crypto system is initialized
  bool get isInitialized => status == CryptoStatus.initialized;

  /// Check if there are any errors
  bool get hasError => errorMessage != null;

  /// Check if any operation is in progress
  bool get isOperationInProgress =>
      isGeneratingKeys ||
      isEncrypting ||
      isDecrypting ||
      isSigning ||
      isVerifying ||
      isExporting ||
      isImporting;

  /// Clear error message
  CryptoState clearError() => copyWith(errorMessage: null);

  @override
  List<Object?> get props => [
    status,
    currentKeyPair,
    currentUserPublicKey,
    lastEncryptedData,
    lastDecryptedData,
    lastSignature,
    lastVerificationResult,
    lastExportedKeys,
    isGeneratingKeys,
    isEncrypting,
    isDecrypting,
    isSigning,
    isVerifying,
    isExporting,
    isImporting,
    errorMessage,
  ];

  @override
  String toString() {
    return 'CryptoState('
        'status: $status, '
        'hasKeyPair: ${currentKeyPair != null}, '
        'publicKey: ${currentUserPublicKey?.substring(0, 10)}..., '
        'isOperationInProgress: $isOperationInProgress, '
        'error: $errorMessage'
        ')';
  }
}
