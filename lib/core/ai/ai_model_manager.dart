import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:katya_ai_rechain_mesh/core/ai/models/ai_model.dart';
import 'package:katya_ai_rechain_mesh/core/error/ai_exceptions.dart';
import 'package:katya_ai_rechain_mesh/core/storage/local_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

/// Manages AI models, including downloading, loading, and managing their lifecycle
class AIModelManager {
  final LocalStorage _localStorage;
  final Map<String, dynamic> _loadedModels = {};
  final Map<String, AIModel> _availableModels = {};

  /// Base directory where models will be stored
  late final Directory _modelsDir;

  /// Whether the manager has been initialized
  bool _isInitialized = false;

  /// Stream controller for model download progress
  final _downloadProgressController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream of download progress updates
  Stream<Map<String, dynamic>> get downloadProgress =>
      _downloadProgressController.stream;

  AIModelManager({required LocalStorage localStorage})
      : _localStorage = localStorage;

  /// Initializes the model manager
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Set up models directory
      final appDir = await getApplicationDocumentsDirectory();
      _modelsDir = Directory(path.join(appDir.path, 'ai_models'));
      if (!await _modelsDir.exists()) {
        await _modelsDir.create(recursive: true);
      }

      // Load available models
      await _loadAvailableModels();

      _isInitialized = true;
    } catch (e, stackTrace) {
      throw AIModelManagerException(
        message: 'Failed to initialize AI Model Manager',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Loads all available models
  Future<void> _loadAvailableModels() async {
    // Add default models
    for (final model in DefaultAIModels.all) {
      _availableModels[model.id] = model.copyWith(
        isDownloaded: await isModelDownloaded(model),
      );
    }

    // TODO: Load custom models from storage/remote config
  }

  /// Gets a model by ID
  Future<AIModel> getModelById(String modelId) async {
    if (!_isInitialized) await initialize();

    final model = _availableModels[modelId];
    if (model == null) {
      throw ModelNotFoundException(modelId);
    }

    return model;
  }

  /// Gets all available models
  Future<List<AIModel>> getAvailableModels() async {
    if (!_isInitialized) await initialize();

    // Update download status for all models
    for (final model in _availableModels.values) {
      _availableModels[model.id] = model.copyWith(
        isDownloaded: await isModelDownloaded(model),
      );
    }

    return _availableModels.values.toList();
  }

  /// Checks if a model is downloaded
  Future<bool> isModelDownloaded(AIModel model) async {
    if (!_isInitialized) await initialize();

    final modelFile = File(path.join(_modelsDir.path, '${model.id}.tflite'));
    return await modelFile.exists();
  }

  /// Downloads a model
  Future<void> downloadModel(AIModel model) async {
    if (!_isInitialized) await initialize();

    if (await isModelDownloaded(model)) {
      return; // Already downloaded
    }

    try {
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(model.modelPath));
      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw ModelDownloadException(
          modelId: model.id,
          error: 'Failed to download model: ${response.statusCode}',
        );
      }

      final totalBytes = response.contentLength ?? 0;
      int receivedBytes = 0;
      final chunks = <List<int>>[];

      // Create the model file
      final modelFile = File(path.join(_modelsDir.path, '${model.id}.tflite'));
      final sink = modelFile.openWrite();

      // Process the response in chunks
      await response.stream.listen(
        (List<int> chunk) {
          receivedBytes += chunk.length;
          chunks.add(chunk);

          // Update progress
          if (totalBytes > 0) {
            final progress = receivedBytes / totalBytes;
            _downloadProgressController.add({
              'modelId': model.id,
              'progress': progress,
              'receivedBytes': receivedBytes,
              'totalBytes': totalBytes,
            });
          }
        },
        onError: (e) {
          sink.close();
          modelFile.deleteSync();
          throw ModelDownloadException(
            modelId: model.id,
            error: 'Download error: $e',
          );
        },
        cancelOnError: true,
      ).asFuture();

      // Write all chunks to file
      for (final chunk in chunks) {
        sink.add(chunk);
      }

      await sink.close();

      // Update model status
      _availableModels[model.id] = model.copyWith(isDownloaded: true);
    } catch (e, stackTrace) {
      throw ModelDownloadException(
        modelId: model.id,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Loads a model into memory
  Future<dynamic> loadModel(AIModel model) async {
    if (!_isInitialized) await initialize();

    // Return already loaded model if available
    if (_loadedModels.containsKey(model.id)) {
      return _loadedModels[model.id];
    }

    // Check if model is downloaded
    if (!await isModelDownloaded(model)) {
      throw ModelNotLoadedException('Model ${model.id} is not downloaded');
    }

    try {
      // Load the model based on framework
      dynamic interpreter;
      final modelPath = path.join(_modelsDir.path, '${model.id}.tflite');

      switch (model.framework.toLowerCase()) {
        case 'tflite':
          // For TFLite models
          // interpreter = await tflite.Interpreter.fromAsset(modelPath);
          // TODO: Implement TFLite model loading
          break;
        case 'pytorch':
          // For PyTorch models
          // TODO: Implement PyTorch model loading
          break;
        default:
          throw UnsupportedError(
              'Unsupported model framework: ${model.framework}');
      }

      throw ModelLoadException(
        modelId: model.id,
        error: 'Failed to load model interpreter',
      );

      // Cache the loaded model
      _loadedModels[model.id] = interpreter;

      return interpreter;
    } catch (e, stackTrace) {
      throw ModelLoadException(
        modelId: model.id,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Unloads a model from memory
  void unloadModel(String modelId) {
    final interpreter = _loadedModels.remove(modelId);

    // Release resources if needed
    if (interpreter != null) {
      // interpreter.close(); // Uncomment if your framework requires cleanup
    }
  }

  /// Deletes a downloaded model
  Future<void> deleteModel(AIModel model) async {
    if (!_isInitialized) await initialize();

    // Unload if currently loaded
    if (_loadedModels.containsKey(model.id)) {
      unloadModel(model.id);
    }

    // Delete model file
    final modelFile = File(path.join(_modelsDir.path, '${model.id}.tflite'));
    if (await modelFile.exists()) {
      await modelFile.delete();
    }

    // Update model status
    _availableModels[model.id] = model.copyWith(isDownloaded: false);
  }

  /// Disposes the model manager and cleans up resources
  Future<void> dispose() async {
    // Unload all models
    for (final modelId in _loadedModels.keys.toList()) {
      unloadModel(modelId);
    }

    // Close the download progress stream
    await _downloadProgressController.close();

    _isInitialized = false;
  }
}

/// Exception specific to AI model management
class AIModelManagerException extends AIException {
  const AIModelManagerException({
    super.message = 'AI Model Manager error',
    super.error,
    super.stackTrace,
  });
}
