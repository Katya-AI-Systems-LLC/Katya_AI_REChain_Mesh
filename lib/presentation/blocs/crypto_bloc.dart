import 'dart:async';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:katya_ai_rechain_mesh/core/domain/usecases/encrypt_message_usecase.dart';
import 'package:katya_ai_rechain_mesh/core/domain/repositories/crypto_repository.dart';

part 'crypto_event.dart';
part 'crypto_state.dart';

/// BLoC for managing cryptographic operations
class CryptoBloc extends Bloc<CryptoEvent, CryptoState> {
  final EncryptMessageUseCase _encryptMessageUseCase;
  final CryptoRepository _cryptoRepository;

  CryptoBloc({
    required EncryptMessageUseCase encryptMessageUseCase,
    required CryptoRepository cryptoRepository,
  })  : _encryptMessageUseCase = encryptMessageUseCase,
        _cryptoRepository = cryptoRepository,
        super(const CryptoState()) {
    on<InitializeCrypto>(_onInitializeCrypto);
    on<GenerateKeyPair>(_onGenerateKeyPair);
    on<EncryptMessage>(_onEncryptMessage);
    on<DecryptMessage>(_onDecryptMessage);
    on<SignData>(_onSignData);
    on<VerifySignature>(_onVerifySignature);
    on<ExportKeyPair>(_onExportKeyPair);
    on<ImportKeyPair>(_onImportKeyPair);
    on<ClearCryptoError>(_onClearCryptoError);
  }

  @override
  Future<void> close() async {
    await _cryptoRepository.dispose();
    return super.close();
  }

  Future<void> _onInitializeCrypto(
    InitializeCrypto event,
    Emitter<CryptoState> emit,
  ) async {
    emit(state.copyWith(status: CryptoStatus.initializing));

    try {
      await _cryptoRepository.initialize();
      emit(state.copyWith(
        status: CryptoStatus.initialized,
        currentUserPublicKey: _cryptoRepository.currentUserPublicKey,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CryptoStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onGenerateKeyPair(
    GenerateKeyPair event,
    Emitter<CryptoState> emit,
  ) async {
    emit(state.copyWith(isGeneratingKeys: true));

    try {
      final keyPair = await _cryptoRepository.generateKeyPair(
        useGOST: event.useGOST,
        useQuantumResistance: event.useQuantumResistance,
      );

      emit(state.copyWith(
        isGeneratingKeys: false,
        currentKeyPair: keyPair,
        currentUserPublicKey: keyPair.publicKey,
      ));
    } catch (e) {
      emit(state.copyWith(
        isGeneratingKeys: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onEncryptMessage(
    EncryptMessage event,
    Emitter<CryptoState> emit,
  ) async {
    emit(state.copyWith(isEncrypting: true));

    try {
      final result = await _encryptMessageUseCase.call(
        data: event.data,
        recipientPublicKey: event.recipientPublicKey,
        useGOST: event.useGOST,
        useQuantumResistance: event.useQuantumResistance,
      );

      result.fold(
        (encryptedData) => emit(state.copyWith(
          isEncrypting: false,
          lastEncryptedData: encryptedData,
        )),
        (error) => emit(state.copyWith(
          isEncrypting: false,
          errorMessage: error,
        )),
      );
    } catch (e) {
      emit(state.copyWith(
        isEncrypting: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDecryptMessage(
    DecryptMessage event,
    Emitter<CryptoState> emit,
  ) async {
    emit(state.copyWith(isDecrypting: true));

    try {
      final decryptedData = await _cryptoRepository.decryptMessage(
        encryptedData: event.encryptedData,
        senderPublicKey: event.senderPublicKey,
      );

      emit(state.copyWith(
        isDecrypting: false,
        lastDecryptedData: decryptedData,
      ));
    } catch (e) {
      emit(state.copyWith(
        isDecrypting: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSignData(
    SignData event,
    Emitter<CryptoState> emit,
  ) async {
    emit(state.copyWith(isSigning: true));

    try {
      final signature = await _cryptoRepository.signData(event.data);

      emit(state.copyWith(
        isSigning: false,
        lastSignature: signature,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSigning: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onVerifySignature(
    VerifySignature event,
    Emitter<CryptoState> emit,
  ) async {
    emit(state.copyWith(isVerifying: true));

    try {
      final isValid = await _cryptoRepository.verifySignature(
        data: event.data,
        signature: event.signature,
        publicKey: event.publicKey,
      );

      emit(state.copyWith(
        isVerifying: false,
        lastVerificationResult: isValid,
      ));
    } catch (e) {
      emit(state.copyWith(
        isVerifying: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onExportKeyPair(
    ExportKeyPair event,
    Emitter<CryptoState> emit,
  ) async {
    emit(state.copyWith(isExporting: true));

    try {
      final exportedKeys = await _cryptoRepository.exportKeyPair();

      emit(state.copyWith(
        isExporting: false,
        lastExportedKeys: exportedKeys,
      ));
    } catch (e) {
      emit(state.copyWith(
        isExporting: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onImportKeyPair(
    ImportKeyPair event,
    Emitter<CryptoState> emit,
  ) async {
    emit(state.copyWith(isImporting: true));

    try {
      await _cryptoRepository.importKeyPair(event.exportedKeys);

      emit(state.copyWith(
        isImporting: false,
        currentUserPublicKey: _cryptoRepository.currentUserPublicKey,
      ));
    } catch (e) {
      emit(state.copyWith(
        isImporting: false,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onClearCryptoError(
    ClearCryptoError event,
    Emitter<CryptoState> emit,
  ) {
    emit(state.clearError());
  }
}
