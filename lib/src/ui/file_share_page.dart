import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/file_service.dart';
import 'components/glass_card.dart';
import 'components/animated_button.dart';

class FileSharePage extends StatefulWidget {
  const FileSharePage({super.key});

  @override
  State<FileSharePage> createState() => _FileSharePageState();
}

class _FileSharePageState extends State<FileSharePage> {
  final FileService _fileService = FileService.instance;
  List<FileInfo> _files = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final files = await _fileService.getFiles();
      setState(() {
        _files = files;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка загрузки файлов: $e'),
          backgroundColor: KatyaTheme.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickFile() async {
    try {
      // Заглушка для демонстрации - создаем тестовый файл
      final testData =
          Uint8List.fromList('Тестовый файл для mesh-сети'.codeUnits);
      await _fileService.saveFile(
          testData, 'test_file_${DateTime.now().millisecondsSinceEpoch}.txt');
      await _loadFiles();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Тестовый файл добавлен'),
          backgroundColor: KatyaTheme.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка создания файла: $e'),
          backgroundColor: KatyaTheme.error,
        ),
      );
    }
  }

  Future<void> _deleteFile(FileInfo file) async {
    try {
      await _fileService.deleteFile(file.path);
      await _loadFiles();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Файл удален'),
          backgroundColor: KatyaTheme.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка удаления файла: $e'),
          backgroundColor: KatyaTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Файлообмен'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFiles,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: KatyaTheme.spaceGradient),
        child: Column(
          children: [
            // Кнопка добавления файлов
            Padding(
              padding: const EdgeInsets.all(20),
              child: AnimatedButton(
                text: 'Добавить файлы',
                icon: Icons.add,
                onPressed: _pickFile,
                width: double.infinity,
              ),
            ),

            // Список файлов
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(KatyaTheme.accent),
                      ),
                    )
                  : _files.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _files.length,
                          itemBuilder: (context, index) {
                            final file = _files[index];
                            return _buildFileCard(file);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: GlassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.folder_open,
              size: 64,
              color: KatyaTheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Нет файлов',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Добавьте файлы для обмена через mesh-сеть',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileCard(FileInfo file) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Иконка файла
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getFileTypeColor(file.name).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getFileTypeIcon(file.name),
              color: _getFileTypeColor(file.name),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Информация о файле
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _fileService.formatFileSize(file.size),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: KatyaTheme.onSurface.withOpacity(0.7),
                      ),
                ),
                Text(
                  _formatDate(file.modified),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: KatyaTheme.onSurface.withOpacity(0.7),
                      ),
                ),
              ],
            ),
          ),

          // Кнопки действий
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Функция отправки в разработке'),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteFile(file),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getFileTypeColor(String fileName) {
    final fileType = _fileService.getFileType(fileName);

    switch (fileType) {
      case FileType.image:
        return KatyaTheme.success;
      case FileType.video:
        return KatyaTheme.primary;
      case FileType.audio:
        return KatyaTheme.accent;
      case FileType.document:
        return KatyaTheme.warning;
      case FileType.other:
        return KatyaTheme.onSurface;
    }
  }

  IconData _getFileTypeIcon(String fileName) {
    final fileType = _fileService.getFileType(fileName);

    switch (fileType) {
      case FileType.image:
        return Icons.image;
      case FileType.video:
        return Icons.videocam;
      case FileType.audio:
        return Icons.audiotrack;
      case FileType.document:
        return Icons.description;
      case FileType.other:
        return Icons.insert_drive_file;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} дн. назад';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ч. назад';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} мин. назад';
    } else {
      return 'Только что';
    }
  }
}
