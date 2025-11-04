import 'dart:async';
import 'dart:typed_data';

import '../../domain/file_payload.dart';
import '../../domain/repositories/file_repository.dart';
import 'base_service.dart';
import '../../domain/file_transfer_status.dart';

/// Service for managing file transfers
class FileService implements LifecycleService, ErrorHandlingService {
  final FileRepository _fileRepository;
  final StreamController<FileTransferProgressInfo> _progressController =
      StreamController<FileTransferProgressInfo>.broadcast();
  final StreamController<ServiceError> _errorController =
      StreamController<ServiceError>.broadcast();
  
  final Map<String, FileTransferProgressInfo> _activeTransfers = {};
  bool _isInitialized = false;
  bool _isRunning = false;
  
  /// Creates a new FileService
  FileService(this._fileRepository);
  
  @override
  String get serviceName => 'FileService';
  
  @override
  bool get isInitialized => _isInitialized;
  
  @override
  bool get isRunning => _isRunning;
  
  @override
  Stream<ServiceError> get errors => _errorController.stream;
  
  /// Stream of file transfer progress updates
  Stream<FileTransferProgressInfo> get transferProgress => _progressController.stream;
  
  /// Gets the progress for a specific file transfer
  FileTransferProgressInfo? getTransferProgress(String fileId) => 
      _activeTransfers[fileId];
  
  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _fileRepository.initialize();
      _isInitialized = true;
    } catch (e, stackTrace) {
      _handleError(
        'Failed to initialize FileService',
        e,
        stackTrace,
        ErrorSeverity.critical,
      );
      rethrow;
    }
  }
  
  @override
  Future<void> start() async {
    if (!_isInitialized) {
      throw StateError('FileService must be initialized before starting');
    }
    
    if (_isRunning) return;
    _isRunning = true;
    
    // Resume any incomplete transfers
    _resumeIncompleteTransfers();
  }
  
  @override
  Future<void> stop() async {
    _isRunning = false;
    
    // Pause all active transfers
    for (final transfer in _activeTransfers.values) {
      if (transfer.status == FileTransferStatus.inProgress) {
        _updateTransferProgress(
          transfer.copyWith(
            status: FileTransferStatus.paused,
          ),
        );
      }
    }
  }
  
  @override
  Future<void> dispose() async {
    await stop();
    await _progressController.close();
    await _errorController.close();
    await _fileRepository.dispose();
    _activeTransfers.clear();
    _isInitialized = false;
  }
  
  /// Starts a new file upload
  Future<FilePayload> startUpload({
    required String filename,
    required String mimeType,
    required int size,
    required String sourcePeerId,
    String? description,
    Map<String, dynamic>? metadata,
    int chunkSize = 1024 * 1024, // 1MB chunks by default
  }) async {
    try {
      // Create file payload
      final filePayload = FilePayload(
        id: _generateFileId(),
        filename: filename,
        mimeType: mimeType,
        size: size,
        checksum: '', // Will be calculated during transfer
        totalChunks: (size / chunkSize).ceil(),
        chunkSize: chunkSize,
        sourcePeerId: sourcePeerId,
        description: description,
        metadata: metadata ?? {},
        status: FileTransferStatus.queued,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Save to repository
      await _fileRepository.save(filePayload);
      
      // Initialize transfer progress
      _updateTransferProgress(
        FileTransferProgressInfo(
          fileId: filePayload.id,
          totalBytes: size,
          transferredBytes: 0,
          bytesPerSecond: 0,
          status: FileTransferStatus.queued,
        ),
      );
      
      return filePayload;
    } catch (e, stackTrace) {
      _handleError(
        'Failed to start file upload',
        e,
        stackTrace,
        ErrorSeverity.error,
      );
      rethrow;
    }
  }
  
  /// Uploads a file chunk
  Future<void> uploadChunk({
    required String fileId,
    required int chunkIndex,
    required Uint8List data,
    bool isLast = false,
  }) async {
    try {
      // Get file payload
      final filePayload = await _fileRepository.findById(fileId);
      if (filePayload == null) {
        throw StateError('File not found: $fileId');
      }
      
      // Create chunk
      final chunk = FileChunk(
        id: '$fileId-chunk-$chunkIndex',
        fileId: fileId,
        index: chunkIndex,
        data: data,
        isLast: isLast,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Save chunk
      await _fileRepository.saveChunk(chunk);
      
      // Update progress
      final progress = _activeTransfers[fileId] ?? FileTransferProgressInfo(
        fileId: fileId,
        totalBytes: filePayload.size,
        transferredBytes: 0,
        bytesPerSecond: 0,
        status: FileTransferStatus.inProgress,
      );
      
      _updateTransferProgress(
        progress.copyWith(
          transferredBytes: (chunkIndex + 1) * filePayload.chunkSize,
          status: isLast ? FileTransferStatus.completed : FileTransferStatus.inProgress,
        ),
      );
      
      // If this is the last chunk, finalize the transfer
      if (isLast) {
        await _finalizeTransfer(fileId);
      }
    } catch (e, stackTrace) {
      _handleError(
        'Failed to upload chunk $chunkIndex for file $fileId',
        e,
        stackTrace,
        ErrorSeverity.error,
      );
      rethrow;
    }
  }
  
  /// Downloads a file
  Future<Uint8List?> downloadFile(String fileId) async {
    try {
      // Check if file exists
      final filePayload = await _fileRepository.findById(fileId);
      if (filePayload == null) {
        throw StateError('File not found: $fileId');
      }
      
      // Check if already downloaded
      if (filePayload.status == FileTransferStatus.completed) {
        return await _fileRepository.assembleFile(fileId);
      }
      
      // Initialize transfer progress
      _updateTransferProgress(
        FileTransferProgressInfo(
          fileId: filePayload.id,
          totalBytes: filePayload.size,
          transferredBytes: 0,
          bytesPerSecond: 0,
          status: FileTransferStatus.queued,
        ),
      );
      
      // Download chunks
      final fileData = await _fileRepository.assembleFile(fileId);
      
      if (fileData != null) {
        _updateTransferProgress(
          FileTransferProgressInfo(
            fileId: fileId,
            totalBytes: filePayload.size,
            transferredBytes: filePayload.size,
            bytesPerSecond: 0,
            status: FileTransferStatus.completed,
          ),
        );
      }
      
      return fileData;
    } catch (e, stackTrace) {
      _handleError(
        'Failed to download file $fileId',
        e,
        stackTrace,
        ErrorSeverity.error,
      );
      rethrow;
    }
  }
  
  /// Cancels a file transfer
  Future<void> cancelTransfer(String fileId) async {
    try {
      // Update status
      final progress = FileTransferProgressInfo(
        fileId: fileId,
        totalBytes: 0,
        transferredBytes: 0,
        bytesPerSecond: 0,
        status: FileTransferStatus.cancelled,
      );
      
      _updateTransferProgress(progress);
      
      // Clean up
      await _fileRepository.delete(fileId);
    } catch (e, stackTrace) {
      _handleError(
        'Failed to cancel transfer for file $fileId',
        e,
        stackTrace,
        ErrorSeverity.warning,
      );
    }
  }
  
  /// Handles an error
  @override
  void handleError(ServiceError error) {
    _errorController.add(error);
  }
  
  // Generates a unique file ID
  String _generateFileId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
  
  // Resumes any incomplete transfers
  Future<void> _resumeIncompleteTransfers() async {
    try {
      final incomplete = await _fileRepository.findIncompleteTransfers();
      for (final file in incomplete) {
        _updateTransferProgress(
          FileTransferProgressInfo(
            fileId: file.id,
            totalBytes: file.size,
            transferredBytes: 0, // Will be updated when chunks are checked
            bytesPerSecond: 0,
            status: FileTransferStatus.queued,
          ),
        );
      }
    } catch (e, stackTrace) {
      _handleError(
        'Failed to resume incomplete transfers',
        e,
        stackTrace,
        ErrorSeverity.error,
      );
    }
  }
  
  // Updates the transfer progress and notifies listeners
  void _updateTransferProgress(FileTransferProgressInfo progress) {
    if (progress.fileId == null) return;
    
    _activeTransfers[progress.fileId!] = progress;
    _progressController.add(progress);
  }
  
  // Finalizes a file transfer
  Future<void> _finalizeTransfer(String fileId) async {
    try {
      // Verify checksum
      final filePayload = await _fileRepository.findById(fileId);
      if (filePayload == null) return;
      
      final isValid = await _fileRepository.validateChecksum(
        fileId,
        filePayload.checksum,
      );
      
      if (!isValid) {
        throw StateError('Checksum validation failed for file $fileId');
      }
      
      // Update status
      _updateTransferProgress(
        FileTransferProgressInfo(
          fileId: fileId,
          totalBytes: filePayload.size,
          transferredBytes: filePayload.size,
          bytesPerSecond: 0,
          status: FileTransferStatus.completed,
        ),
      );
    } catch (e, stackTrace) {
      _handleError(
        'Failed to finalize transfer for file $fileId',
        e,
        stackTrace,
        ErrorSeverity.error,
      );
      rethrow;
    }
  }
  
  // Handles an error
  void _handleError(
    String message,
    dynamic error,
    StackTrace stackTrace, 
    ErrorSeverity severity,
  ) {
    final serviceError = ServiceError(
      message: '$message: $error',
      stackTrace: stackTrace,
      severity: severity,
    );
    _errorController.add(serviceError);
  }
}
