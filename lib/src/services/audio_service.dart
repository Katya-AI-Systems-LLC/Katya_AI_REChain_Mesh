import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'crypto_helper.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  static AudioService get instance => _instance;
  AudioService._internal();

  final StreamController<AudioRecordingState> _recordingStateController =
      StreamController.broadcast();
  final StreamController<AudioPlaybackState> _playbackStateController =
      StreamController.broadcast();

  Stream<AudioRecordingState> get recordingState =>
      _recordingStateController.stream;
  Stream<AudioPlaybackState> get playbackState =>
      _playbackStateController.stream;

  /// Получение директории для хранения аудио файлов
  Future<Directory> getAudioDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory(path.join(appDir.path, 'audio_messages'));

    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }

    return audioDir;
  }

  /// Начало записи аудио
  Future<void> startRecording() async {
    try {
      // Здесь должна быть логика записи аудио
      // Для демонстрации используем заглушку
      _recordingStateController.add(AudioRecordingState.recording);

      print('Audio recording started');
    } catch (e) {
      print('Failed to start recording: $e');
      _recordingStateController.add(AudioRecordingState.error);
    }
  }

  /// Остановка записи аудио
  Future<String?> stopRecording() async {
    try {
      _recordingStateController.add(AudioRecordingState.stopped);

      // Здесь должна быть логика остановки записи
      // Для демонстрации создаем заглушку
      final audioDir = await getAudioDirectory();
      final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.wav';
      final filePath = path.join(audioDir.path, fileName);

      // Создаем пустой файл для демонстрации
      final file = File(filePath);
      await file.writeAsBytes(Uint8List(0));

      print('Audio recording stopped: $filePath');
      return filePath;
    } catch (e) {
      print('Failed to stop recording: $e');
      _recordingStateController.add(AudioRecordingState.error);
      return null;
    }
  }

  /// Воспроизведение аудио
  Future<void> playAudio(String filePath) async {
    try {
      _playbackStateController.add(AudioPlaybackState.playing);

      // Здесь должна быть логика воспроизведения аудио
      // Для демонстрации используем заглушку
      await Future.delayed(const Duration(seconds: 2));

      _playbackStateController.add(AudioPlaybackState.stopped);

      print('Audio playback completed: $filePath');
    } catch (e) {
      print('Failed to play audio: $e');
      _playbackStateController.add(AudioPlaybackState.error);
    }
  }

  /// Остановка воспроизведения
  Future<void> stopPlayback() async {
    try {
      _playbackStateController.add(AudioPlaybackState.stopped);
      print('Audio playback stopped');
    } catch (e) {
      print('Failed to stop playback: $e');
    }
  }

  /// Шифрование аудио файла
  Future<Uint8List> encryptAudio(Uint8List audioData, List<int> key) async {
    try {
      final encrypted = await CryptoHelper.encrypt(
        String.fromCharCodes(audioData),
        key,
      );

      // Создаем структуру зашифрованного аудио
      final encryptedAudio = {
        'ciphertext': encrypted['ciphertext'],
        'nonce': encrypted['nonce'],
        'mac': encrypted['mac'],
        'originalSize': audioData.length,
        'type': 'audio',
      };

      return Uint8List.fromList(
        encryptedAudio.toString().codeUnits,
      );
    } catch (e) {
      print('Failed to encrypt audio: $e');
      rethrow;
    }
  }

  /// Расшифрование аудио файла
  Future<Uint8List> decryptAudio(Uint8List encryptedData, List<int> key) async {
    try {
      // Парсим структуру зашифрованного аудио
      final encryptedAudio = Map<String, dynamic>.from(
        jsonDecode(String.fromCharCodes(encryptedData)),
      );

      final decrypted = await CryptoHelper.decrypt(
        {
          'ciphertext': encryptedAudio['ciphertext'],
          'nonce': encryptedAudio['nonce'],
          'mac': encryptedAudio['mac'],
        },
        key,
      );

      return Uint8List.fromList(decrypted.codeUnits);
    } catch (e) {
      print('Failed to decrypt audio: $e');
      rethrow;
    }
  }

  /// Получение длительности аудио файла
  Future<Duration> getAudioDuration(String filePath) async {
    try {
      // Здесь должна быть логика получения длительности
      // Для демонстрации возвращаем случайную длительность
      return Duration(seconds: 30 + (DateTime.now().millisecond % 60));
    } catch (e) {
      print('Failed to get audio duration: $e');
      return Duration.zero;
    }
  }

  /// Получение размера аудио файла
  Future<int> getAudioFileSize(String filePath) async {
    try {
      final file = File(filePath);

      if (await file.exists()) {
        final stat = await file.stat();
        return stat.size;
      }

      return 0;
    } catch (e) {
      print('Failed to get audio file size: $e');
      return 0;
    }
  }

  /// Форматирование длительности аудио
  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    if (minutes > 0) {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '0:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Очистка ресурсов
  void dispose() {
    _recordingStateController.close();
    _playbackStateController.close();
  }
}

enum AudioRecordingState {
  idle,
  recording,
  stopped,
  error,
}

enum AudioPlaybackState {
  idle,
  playing,
  stopped,
  error,
}
