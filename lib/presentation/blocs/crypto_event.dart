part of 'crypto_bloc.dart';

/// Base class for crypto-related events
abstract class CryptoEvent extends Equatable {
  const CryptoEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize the crypto system
class InitializeCrypto extends CryptoEvent {
  const InitializeCrypto();
}

/// Event to generate a new key pair
class GenerateKeyPair extends CryptoEvent {
  final bool useGOST;
  final bool useQuantumResistance;

  const GenerateKeyPair({
    this.useGOST = true,
    this.useQuantumResistance = false,
  });

  @override
  List<Object?> get props => [useGOST, useQuantumResistance];
}

/// Event to encrypt data
class EncryptMessage extends CryptoEvent {
  final Uint8List data;
  final String recipientPublicKey;
  final bool useGOST;
  final bool useQuantumResistance;

  const EncryptMessage({
    required this.data,
    required this.recipientPublicKey,
    this.useGOST = true,
    this.useQuantumResistance = false,
  });

  @override
  List<Object?> get props => [data, recipientPublicKey, useGOST, useQuantumResistance];
}

/// Event to decrypt data
class DecryptMessage extends CryptoEvent {
  final Uint8List encryptedData;
  final String senderPublicKey;

  const DecryptMessage({
    required this.encryptedData,
    required this.senderPublicKey,
  });

  @override
  List<Object?> get props => [encryptedData, senderPublicKey];
}

/// Event to sign data
class SignData extends CryptoEvent {
  final Uint8List data;

  const SignData(this.data);

  @override
  List<Object?> get props => [data];
}

/// Event to verify signature
class VerifySignature extends CryptoEvent {
  final Uint8List data;
  final Uint8List signature;
  final String publicKey;

  const VerifySignature({
    required this.data,
    required this.signature,
    required this.publicKey,
  });

  @override
  List<Object?> get props => [data, signature, publicKey];
}

/// Event to export key pair
class ExportKeyPair extends CryptoEvent {
  const ExportKeyPair();
}

/// Event to import key pair
class ImportKeyPair extends CryptoEvent {
  final String exportedKeys;

  const ImportKeyPair(this.exportedKeys);

  @override
  List<Object?> get props => [exportedKeys];
}

/// Event to clear crypto error
class ClearCryptoError extends CryptoEvent {
  const ClearCryptoError();
}
