import 'dart:typed_data';

import '../../domain/file_payload.dart';
import '../../domain/file_transfer_status.dart';
import 'base_repository.dart';

/// Represents the progress of a file transfer
class FileTransferProgressInfo {
  /// The ID of the file being transferred
  final String? fileId;
  
  /// Total size of the file in bytes
  final int totalBytes;
  
  /// Number of bytes transferred so far
  final int transferredBytes;
  
  /// Transfer speed in bytes per second
  final double bytesPerSecond;
  
  /// Current status of the transfer
  final FileTransferStatus status;
  
  /// Error message if the transfer failed
  final String? error;
  
  /// Timestamp when the transfer started
  final DateTime? startTime;
  
  /// Estimated time remaining in seconds
  double? get estimatedTimeRemaining {
    if (bytesPerSecond <= 0) return null;
    return (totalBytes - transferredBytes) / bytesPerSecond;
  }
  
  /// Percentage of transfer completed (0.0 to 1.0)
  double get progress => totalBytes > 0 ? transferredBytes / totalBytes : 0.0;
  
  /// Creates a new FileTransferProgressInfo
  const FileTransferProgressInfo({
    this.fileId,
    required this.totalBytes,
    required this.transferredBytes,
    required this.bytesPerSecond,
    required this.status,
    this.error,
    this.startTime,
  });
  
  /// Creates a copy of this progress with updated fields
  FileTransferProgressInfo copyWith({
    String? fileId,
    int? totalBytes,
    int? transferredBytes,
    double? bytesPerSecond,
FileTransferStatus? status,
    String? error,
    DateTime? startTime,
  }) {
    return FileTransferProgressInfo(
      fileId: fileId ?? this.fileId,
      totalBytes: totalBytes ?? this.totalBytes,
      transferredBytes: transferredBytes ?? this.transferredBytes,
      bytesPerSecond: bytesPerSecond ?? this.bytesPerSecond,
      status: status ?? this.status,
      error: error ?? this.error,
      startTime: startTime ?? this.startTime,
    );
  }
}

/// Mixin for repositories that need lifecycle management
abstract class LifecycleRepository {
  /// Initializes the repository
  Future<void> initialize();
  
  /// Disposes resources used by the repository
  Future<void> dispose();
}

/// Repository for managing file transfers
abstract class FileRepository extends BaseRepository<FilePayload> implements LifecycleRepository {
  /// Saves a file chunk
  Future<void> saveChunk(FileChunk chunk);
  
  /// Retrieves a file chunk by file ID and index
  Future<FileChunk?> getChunk(String fileId, int index);
  
  /// Retrieves all chunks for a file
  Future<List<FileChunk>> getChunks(String fileId);
  
  /// Checks if a chunk exists
  Future<bool> hasChunk(String fileId, int index);
  
  /// Gets the transfer progress of a file
  Future<FileTransferProgressInfo> getTransferProgress(String fileId);
  
  /// Updates the transfer progress of a file
  Future<void> updateTransferProgress(FileTransferProgressInfo progress);
  
  /// Stream of transfer progress updates
  Stream<FileTransferProgressInfo> watchTransferProgress(String fileId);
  
  /// Initializes the repository
  @override
  Future<void> initialize();
  
  /// Disposes resources used by the repository
  @override
  Future<void> dispose();
  
  /// Finds files shared by a specific peer
  Future<List<FilePayload>> findByPeer(String peerId, {bool includeCompleted = true});
  
  /// Finds files by MIME type
  Future<List<FilePayload>> findByType(String mimeType, {String? peerId});
  
  /// Finds incomplete file transfers
  Future<List<FilePayload>> findIncompleteTransfers();
  
  /// Assembles a file from its chunks
  /// Returns the complete file data if all chunks are available
  Future<Uint8List?> assembleFile(String fileId);
  
  /// Validates the checksum of an assembled file
  Future<bool> validateChecksum(String fileId, String expectedChecksum);
  
  /// Cleans up temporary files and chunks
  Future<int> cleanup({Duration? maxAge, bool onlyCompleted = true});
  
  /// Gets the total storage used by files
  Future<int> getStorageUsage({String? peerId});
  
  /// Stream of active file transfers
  Stream<List<FilePayload>> watchActiveTransfers();
}

/// Repository for managing file storage
abstract class FileStorageRepository {
  /// Saves a file to persistent storage
  /// Returns the path where the file was saved
  Future<String> saveFile({
    required String fileId,
    required Uint8List data,
    required String filename,
    String? directory,
    bool overwrite = false,
  });
  
  /// Reads a file from persistent storage
  Future<Uint8List> readFile(String filePath);
  
  /// Deletes a file from persistent storage
  Future<bool> deleteFile(String filePath);
  
  /// Gets information about a file
  Future<FileInfo> getFileInfo(String filePath);
  
  /// Lists files in a directory
  Future<List<FileInfo>> listFiles({
    required String directory,
    bool recursive = false,
    String? pattern,
  });
  
  /// Gets the available storage space in bytes
  Future<int> getAvailableSpace();
  
  /// Gets the total storage capacity in bytes
  Future<int> getTotalSpace();
  
  /// Creates a directory if it doesn't exist
  Future<void> ensureDirectory(String path);
  
  /// Cleans up temporary files
  Future<int> cleanupTemporaryFiles({Duration? maxAge});
}

/// Information about a file
class FileInfo {
  /// File path
  final String path;
  
  /// File name
  final String name;
  
  /// File size in bytes
  final int size;
  
  /// File MIME type
  final String mimeType;
  
  /// File creation time
  final DateTime createdAt;
  
  /// Last modified time
  final DateTime modifiedAt;
  
  /// Whether the file is a directory
  final bool isDirectory;
  
  /// File extension (without the dot)
  final String extension;
  
  /// File permissions
  final String? permissions;

  const FileInfo({
    required this.path,
    required this.name,
    required this.size,
    required this.mimeType,
    required this.createdAt,
    required this.modifiedAt,
    required this.isDirectory,
    required this.extension,
    this.permissions,
  });

  /// Whether the file is an image
  bool get isImage => mimeType.startsWith('image/');
  
  /// Whether the file is a video
  bool get isVideo => mimeType.startsWith('video/');
  
  /// Whether the file is an audio file
  bool get isAudio => mimeType.startsWith('audio/');
  
  /// Whether the file is a document
  bool get isDocument => 
      mimeType == 'application/pdf' ||
      mimeType == 'application/msword' ||
      mimeType == 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' ||
      mimeType == 'application/vnd.ms-excel' ||
      mimeType == 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ||
      mimeType == 'application/vnd.ms-powerpoint' ||
      mimeType == 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
  
  /// Whether the file is compressed
  bool get isCompressed => 
      mimeType == 'application/zip' ||
      mimeType == 'application/x-rar-compressed' ||
      mimeType == 'application/x-7z-compressed' ||
      mimeType == 'application/x-tar' ||
      mimeType == 'application/gzip';
  
  /// File size in a human-readable format
  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  @override
  String toString() => 'FileInfo(' 
      'name: $name, '
      'size: $formattedSize, '
      'type: $mimeType, '
      'path: $path'
      ')';
}
