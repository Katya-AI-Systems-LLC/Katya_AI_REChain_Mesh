import 'package:equatable/equatable.dart';

/// Represents the status of a file transfer
enum FileTransferStatus {
  queued,
  inProgress,
  paused,
  completed,
  failed,
  cancelled,
}

/// Represents the progress of a file transfer
class FileTransferProgressInfo extends Equatable {
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
  
  @override
  List<Object?> get props => [
    fileId,
    totalBytes,
    transferredBytes,
    bytesPerSecond,
    status,
    error,
    startTime,
  ];
}
