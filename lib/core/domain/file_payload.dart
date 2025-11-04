import 'dart:typed_data';

import 'base_entity.dart';
import 'file_transfer_status.dart';

/// Represents a file payload that can be transferred over the mesh network
class FilePayload extends BaseEntity {
  /// Original filename
  final String filename;
  
  /// MIME type of the file
  final String mimeType;
  
  /// Size of the file in bytes
  final int size;
  
  /// SHA-256 checksum of the file
  final String checksum;
  
  /// Number of chunks the file is split into
  final int totalChunks;
  
  /// Size of each chunk in bytes (except possibly the last one)
  final int chunkSize;
  
  /// ID of the peer who originally shared the file
  final String sourcePeerId;
  
  /// Optional description of the file
  final String? description;
  
  /// Optional metadata
  final Map<String, dynamic> metadata;
  
  /// Current status of the file transfer
  final FileTransferStatus status;
  
  /// Optional encryption metadata if the file is encrypted
  final Map<String, dynamic>? encryptionMetadata;
  
  /// Optional compression information
  final Map<String, dynamic>? compressionInfo;

  const FilePayload({
    required super.id,
    required this.filename,
    required this.mimeType,
    required this.size,
    required this.checksum,
    required this.totalChunks,
    required this.chunkSize,
    required this.sourcePeerId,
    this.description,
    this.metadata = const {},
    this.status = FileTransferStatus.queued,
    this.encryptionMetadata,
    this.compressionInfo,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Creates a copy of the file payload with updated fields
  @override
  FilePayload copyWith({
    String? id,
    String? filename,
    String? mimeType,
    int? size,
    String? checksum,
    int? totalChunks,
    int? chunkSize,
    String? sourcePeerId,
    String? description,
    Map<String, dynamic>? metadata,
    FileTransferStatus? status,
    Map<String, dynamic>? encryptionMetadata,
    Map<String, dynamic>? compressionInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FilePayload(
      id: id ?? this.id,
      filename: filename ?? this.filename,
      mimeType: mimeType ?? this.mimeType,
      size: size ?? this.size,
      checksum: checksum ?? this.checksum,
      totalChunks: totalChunks ?? this.totalChunks,
      chunkSize: chunkSize ?? this.chunkSize,
      sourcePeerId: sourcePeerId ?? this.sourcePeerId,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
      status: status ?? this.status,
      encryptionMetadata: encryptionMetadata ?? this.encryptionMetadata,
      compressionInfo: compressionInfo ?? this.compressionInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Creates a FilePayload from a file chunk
  FileChunk createChunk({
    required int index,
    required Uint8List data,
    bool isLast = false,
  }) {
    return FileChunk(
      id: '$id-chunk-$index',
      fileId: id,
      index: index,
      data: data,
      isLast: isLast,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        filename,
        mimeType,
        size,
        checksum,
        totalChunks,
        chunkSize,
        sourcePeerId,
        description,
        metadata,
        status,
        encryptionMetadata,
        compressionInfo,
      ];

  /// Creates a FilePayload from JSON
  factory FilePayload.fromJson(Map<String, dynamic> json) {
    return FilePayload(
      id: json['id'] as String,
      filename: json['filename'] as String,
      mimeType: json['mimeType'] as String,
      size: json['size'] as int,
      checksum: json['checksum'] as String,
      totalChunks: json['totalChunks'] as int,
      chunkSize: json['chunkSize'] as int,
      sourcePeerId: json['sourcePeerId'] as String,
      description: json['description'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
      status: FileTransferStatus.values.firstWhere(
        (e) => e.toString() == 'FileTransferStatus.${json['status']}',
        orElse: () => FileTransferStatus.queued,
      ),
      encryptionMetadata: json['encryptionMetadata'] != null
          ? Map<String, dynamic>.from(
              json['encryptionMetadata'] as Map<String, dynamic>)
          : null,
      compressionInfo: json['compressionInfo'] != null
          ? Map<String, dynamic>.from(
              json['compressionInfo'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Converts the FilePayload to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'mimeType': mimeType,
      'size': size,
      'checksum': checksum,
      'totalChunks': totalChunks,
      'chunkSize': chunkSize,
      'sourcePeerId': sourcePeerId,
      if (description != null) 'description': description,
      'metadata': metadata,
      'status': status.toString().split('.').last,
      if (encryptionMetadata != null) 'encryptionMetadata': encryptionMetadata,
      if (compressionInfo != null) 'compressionInfo': compressionInfo,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Gets the file extension from the filename
  String get fileExtension {
    final dotIndex = filename.lastIndexOf('.');
    if (dotIndex == -1) return '';
    return filename.substring(dotIndex + 1).toLowerCase();
  }

  /// Whether the file is an image
  bool get isImage => mimeType.startsWith('image/');

  /// Whether the file is a video
  bool get isVideo => mimeType.startsWith('video/');

  /// Whether the file is an audio file
  bool get isAudio => mimeType.startsWith('audio/');

  /// Whether the file is a document
  bool get isDocument => mimeType == 'application/pdf' ||
      mimeType == 'application/msword' ||
      mimeType == 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' ||
      mimeType == 'application/vnd.ms-excel' ||
      mimeType == 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ||
      mimeType == 'application/vnd.ms-powerpoint' ||
      mimeType == 'application/vnd.openxmlformats-officedocument.presentationml.presentation';

  /// Whether the file is compressed
  bool get isCompressed => mimeType == 'application/zip' ||
      mimeType == 'application/x-rar-compressed' ||
      mimeType == 'application/x-7z-compressed' ||
      mimeType == 'application/x-tar' ||
      mimeType == 'application/gzip';
}

/// Represents a chunk of a file
class FileChunk extends BaseEntity {
  /// ID of the file this chunk belongs to
  final String fileId;
  
  /// Zero-based index of the chunk
  final int index;
  
  /// The actual chunk data
  final Uint8List data;
  
  /// Whether this is the last chunk
  final bool isLast;
  
  /// Optional checksum of the chunk
  final String? checksum;
  
  /// Optional sequence number for ordering
  final int? sequenceNumber;

  const FileChunk({
    required super.id,
    required this.fileId,
    required this.index,
    required this.data,
    this.isLast = false,
    this.checksum,
    this.sequenceNumber,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Creates a copy of the file chunk with updated fields
  @override
  FileChunk copyWith({
    String? id,
    String? fileId,
    int? index,
    Uint8List? data,
    bool? isLast,
    String? checksum,
    int? sequenceNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FileChunk(
      id: id ?? this.id,
      fileId: fileId ?? this.fileId,
      index: index ?? this.index,
      data: data ?? this.data,
      isLast: isLast ?? this.isLast,
      checksum: checksum ?? this.checksum,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        fileId,
        index,
        data,
        isLast,
        checksum,
        sequenceNumber,
      ];

  /// Creates a FileChunk from JSON
  factory FileChunk.fromJson(Map<String, dynamic> json) {
    return FileChunk(
      id: json['id'] as String,
      fileId: json['fileId'] as String,
      index: json['index'] as int,
      data: Uint8List.fromList(
          (json['data'] as List).map((e) => e as int).toList()),
      isLast: json['isLast'] as bool? ?? false,
      checksum: json['checksum'] as String?,
      sequenceNumber: json['sequenceNumber'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Converts the FileChunk to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileId': fileId,
      'index': index,
      'data': data.toList(),
      'isLast': isLast,
      if (checksum != null) 'checksum': checksum,
      if (sequenceNumber != null) 'sequenceNumber': sequenceNumber,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Size of the chunk in bytes
  int get size => data.length;
}

// FileTransferStatus has been moved to file_transfer_status.dart

/// Progress of a file transfer
class FileTransferProgress {
  /// Total number of bytes to transfer
  final int totalBytes;
  
  /// Number of bytes transferred so far
  final int transferredBytes;
  
  /// Current transfer speed in bytes per second
  final double bytesPerSecond;
  
  /// Estimated time remaining in seconds
  final double? estimatedTimeRemaining;
  
  /// Current status of the transfer
  final FileTransferStatus status;
  
  /// Optional error message if the transfer failed
  final String? error;

  const FileTransferProgress({
    required this.totalBytes,
    required this.transferredBytes,
    required this.bytesPerSecond,
    this.estimatedTimeRemaining,
    this.status = FileTransferStatus.queued,
    this.error,
  });

  /// Progress as a value between 0.0 and 1.0
  double get progress =>
      totalBytes > 0 ? transferredBytes / totalBytes : 0.0;

  /// Whether the transfer is complete
  bool get isComplete => status == FileTransferStatus.completed;

  /// Whether the transfer has failed
  bool get hasError => status == FileTransferStatus.failed && error != null;

  /// Creates a copy of the progress with updated fields
  FileTransferProgress copyWith({
    int? totalBytes,
    int? transferredBytes,
    double? bytesPerSecond,
    double? estimatedTimeRemaining,
    FileTransferStatus? status,
    String? error,
  }) {
    return FileTransferProgress(
      totalBytes: totalBytes ?? this.totalBytes,
      transferredBytes: transferredBytes ?? this.transferredBytes,
      bytesPerSecond: bytesPerSecond ?? this.bytesPerSecond,
      estimatedTimeRemaining: estimatedTimeRemaining ?? this.estimatedTimeRemaining,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  @override
  String toString() {
    return 'FileTransferProgress(' 
        'progress: ${(progress * 100).toStringAsFixed(1)}%, '
        'transferred: $transferredBytes/$totalBytes bytes, '
        'speed: ${(bytesPerSecond / 1024).toStringAsFixed(1)} KB/s, '
        'status: $status${error != null ? ', error: $error' : ''}'
        ')';
  }
}
