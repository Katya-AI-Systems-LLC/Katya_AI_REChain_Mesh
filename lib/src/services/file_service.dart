import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'crypto_helper.dart';

class FileService {
  static final FileService _instance = FileService._internal();
  factory FileService() => _instance;
  static FileService get instance => _instance;
  FileService._internal();

  /// Получение директории для хранения файлов
  Future<Directory> getFilesDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final filesDir = Directory(path.join(appDir.path, 'mesh_files'));

    if (!await filesDir.exists()) {
      await filesDir.create(recursive: true);
    }

    return filesDir;
  }

  /// Сохранение файла
  Future<String> saveFile(Uint8List data, String fileName) async {
    try {
      final filesDir = await getFilesDirectory();
      final file = File(path.join(filesDir.path, fileName));

      await file.writeAsBytes(data);

      print('File saved: ${file.path}');
      return file.path;
    } catch (e) {
      print('Failed to save file: $e');
      rethrow;
    }
  }

  /// Загрузка файла
  Future<Uint8List> loadFile(String filePath) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        throw Exception('File does not exist: $filePath');
      }

      return await file.readAsBytes();
    } catch (e) {
      print('Failed to load file: $e');
      rethrow;
    }
  }

  /// Получение списка файлов
  Future<List<FileInfo>> getFiles() async {
    try {
      final filesDir = await getFilesDirectory();
      final files = await filesDir.list().toList();

      final fileInfos = <FileInfo>[];

      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          fileInfos.add(FileInfo(
            name: path.basename(file.path),
            path: file.path,
            size: stat.size,
            modified: stat.modified,
          ));
        }
      }

      // Сортируем по дате изменения (новые сначала)
      fileInfos.sort((a, b) => b.modified.compareTo(a.modified));

      return fileInfos;
    } catch (e) {
      print('Failed to get files: $e');
      return [];
    }
  }

  /// Удаление файла
  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);

      if (await file.exists()) {
        await file.delete();
        print('File deleted: $filePath');
      }
    } catch (e) {
      print('Failed to delete file: $e');
      rethrow;
    }
  }

  /// Шифрование файла
  Future<Uint8List> encryptFile(Uint8List data, List<int> key) async {
    try {
      final encrypted = await CryptoHelper.encrypt(
        String.fromCharCodes(data),
        key,
      );

      // Создаем структуру зашифрованного файла
      final encryptedFile = {
        'ciphertext': encrypted['ciphertext'],
        'nonce': encrypted['nonce'],
        'mac': encrypted['mac'],
        'originalSize': data.length,
      };

      return Uint8List.fromList(
        encryptedFile.toString().codeUnits,
      );
    } catch (e) {
      print('Failed to encrypt file: $e');
      rethrow;
    }
  }

  /// Расшифрование файла
  Future<Uint8List> decryptFile(Uint8List encryptedData, List<int> key) async {
    try {
      // Парсим структуру зашифрованного файла
      final encryptedFile = Map<String, dynamic>.from(
        jsonDecode(String.fromCharCodes(encryptedData)),
      );

      final decrypted = await CryptoHelper.decrypt(
        {
          'ciphertext': encryptedFile['ciphertext'],
          'nonce': encryptedFile['nonce'],
          'mac': encryptedFile['mac'],
        },
        key,
      );

      return Uint8List.fromList(decrypted.codeUnits);
    } catch (e) {
      print('Failed to decrypt file: $e');
      rethrow;
    }
  }

  /// Получение размера файла в читаемом формате
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Получение расширения файла
  String getFileExtension(String fileName) {
    return path.extension(fileName).toLowerCase();
  }

  /// Проверка типа файла
  FileType getFileType(String fileName) {
    final extension = getFileExtension(fileName);

    if (['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp']
        .contains(extension)) {
      return FileType.image;
    } else if (['.mp4', '.avi', '.mov', '.mkv', '.webm'].contains(extension)) {
      return FileType.video;
    } else if (['.mp3', '.wav', '.aac', '.flac', '.ogg'].contains(extension)) {
      return FileType.audio;
    } else if (['.pdf', '.doc', '.docx', '.txt', '.rtf'].contains(extension)) {
      return FileType.document;
    } else {
      return FileType.other;
    }
  }
}

class FileInfo {
  final String name;
  final String path;
  final int size;
  final DateTime modified;

  FileInfo({
    required this.name,
    required this.path,
    required this.size,
    required this.modified,
  });
}

enum FileType {
  image,
  video,
  audio,
  document,
  other,
}
