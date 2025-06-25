import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:yaffuu/domain/common/logger.dart';

enum CleanupStrategy {
  oldestFirst,
  largestFirst,
  leastRecentlyUsed,
}

class OutputFileManager {
  final Directory dataDir;
  final int maxSizeBytes;
  final int maxFiles;
  final CleanupStrategy cleanupStrategy;

  static const String _outputSubdir = 'outputs';
  static const String _metadataFile = '.file_metadata.json';

  OutputFileManager({
    required this.dataDir,
    this.maxSizeBytes = 1024 * 1024 * 1024, // 1GB default
    this.maxFiles = 100, // 100 files default
    this.cleanupStrategy = CleanupStrategy.oldestFirst,
  });

  Directory get outputDirectory =>
      Directory(path.join(dataDir.path, _outputSubdir));

  Future<void> initialize() async {
    if (!await outputDirectory.exists()) {
      await outputDirectory.create(recursive: true);
    }

    await _cleanupIfNeeded();
  }

  Future<File> saveOutputFile(File sourceFile, {String? customName}) async {
    await initialize();

    final fileName = customName ?? _generateFileName(sourceFile);
    final targetFile = File(path.join(outputDirectory.path, fileName));

    final copiedFile = await sourceFile.copy(targetFile.path);

    await _updateFileMetadata(copiedFile);

    await _cleanupIfNeeded();

    logger.d('Output file saved: ${copiedFile.path}');
    return copiedFile;
  }

  Future<int> getCurrentSize() async {
    if (!await outputDirectory.exists()) return 0;

    int totalSize = 0;
    await for (final entity in outputDirectory.list(recursive: true)) {
      if (entity is File) {
        final stat = await entity.stat();
        totalSize += stat.size;
      }
    }
    return totalSize;
  }

  Future<int> getCurrentFileCount() async {
    if (!await outputDirectory.exists()) return 0;

    int count = 0;
    await for (final entity in outputDirectory.list()) {
      if (entity is File && !entity.path.endsWith(_metadataFile)) {
        count++;
      }
    }
    return count;
  }

  Future<List<OutputFileInfo>> getOutputFiles() async {
    if (!await outputDirectory.exists()) return [];

    final files = <OutputFileInfo>[];
    await for (final entity in outputDirectory.list()) {
      if (entity is File && !entity.path.endsWith(_metadataFile)) {
        final stat = await entity.stat();
        final info = OutputFileInfo(
          file: entity,
          size: stat.size,
          created: stat.changed,
          modified: stat.modified,
          lastAccessed: await _getLastAccessTime(entity),
        );
        files.add(info);
      }
    }

    return files;
  }

  Future<bool> deleteOutputFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
        await _removeFileMetadata(file);
        logger.d('Deleted output file: ${file.path}');
        return true;
      }
    } catch (e) {
      logger.e('Failed to delete output file: ${file.path}, error: $e');
    }
    return false;
  }

  Future<void> clearAllFiles() async {
    if (!await outputDirectory.exists()) return;

    await for (final entity in outputDirectory.list()) {
      if (entity is File) {
        try {
          await entity.delete();
        } catch (e) {
          logger.e('Failed to delete file: ${entity.path}, error: $e');
        }
      }
    }
    logger.d('Cleared all output files');
  }

  Future<StorageStats> getStorageStats() async {
    final currentSize = await getCurrentSize();
    final currentFiles = await getCurrentFileCount();

    return StorageStats(
      currentSize: currentSize,
      maxSize: maxSizeBytes,
      currentFiles: currentFiles,
      maxFiles: maxFiles,
      usagePercentage: (currentSize / maxSizeBytes * 100).clamp(0, 100),
    );
  }

  Future<void> _cleanupIfNeeded() async {
    final currentSize = await getCurrentSize();
    final currentFiles = await getCurrentFileCount();

    if (currentSize <= maxSizeBytes && currentFiles <= maxFiles) {
      return;
    }

    logger.d(
        'Cleanup needed - Size: ${_formatBytes(currentSize)}/$_formatBytes(maxSizeBytes)}, Files: $currentFiles/$maxFiles');

    final files = await getOutputFiles();

    files.sort((a, b) {
      switch (cleanupStrategy) {
        case CleanupStrategy.oldestFirst:
          return a.created.compareTo(b.created);
        case CleanupStrategy.largestFirst:
          return b.size.compareTo(a.size);
        case CleanupStrategy.leastRecentlyUsed:
          return a.lastAccessed.compareTo(b.lastAccessed);
      }
    });

    int deletedSize = 0;
    int deletedCount = 0;

    for (final fileInfo in files) {
      if (currentSize - deletedSize <= maxSizeBytes &&
          currentFiles - deletedCount <= maxFiles) {
        break;
      }

      if (await deleteOutputFile(fileInfo.file)) {
        deletedSize += fileInfo.size;
        deletedCount++;
      }
    }

    if (deletedCount > 0) {
      logger.d(
          'Cleanup completed - Deleted $deletedCount files (${_formatBytes(deletedSize)})');
    }
  }

  String _generateFileName(File sourceFile) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final originalName = path.basenameWithoutExtension(sourceFile.path);
    final extension = path.extension(sourceFile.path);
    return '${timestamp}_$originalName$extension';
  }

  Future<void> _updateFileMetadata(File file) async {
    try {
      await file.setLastAccessed(DateTime.now());
    } catch (e) {
      logger.w('Could not update access time for ${file.path}: $e');
    }
  }

  Future<DateTime> _getLastAccessTime(File file) async {
    try {
      final stat = await file.stat();
      return stat.accessed;
    } catch (e) {
      final stat = await file.stat();
      return stat.modified;
    }
  }

  Future<void> _removeFileMetadata(File file) async {}

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}

class OutputFileInfo {
  final File file;
  final int size;
  final DateTime created;
  final DateTime modified;
  final DateTime lastAccessed;

  OutputFileInfo({
    required this.file,
    required this.size,
    required this.created,
    required this.modified,
    required this.lastAccessed,
  });

  String get name => path.basename(file.path);
  String get extension => path.extension(file.path);
  String get formattedSize => _formatBytes(size);

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}

class StorageStats {
  final int currentSize;
  final int maxSize;
  final int currentFiles;
  final int maxFiles;
  final double usagePercentage;

  StorageStats({
    required this.currentSize,
    required this.maxSize,
    required this.currentFiles,
    required this.maxFiles,
    required this.usagePercentage,
  });

  bool get isNearLimit => usagePercentage > 80;
  bool get isAtLimit => usagePercentage >= 95;

  String get formattedCurrentSize => _formatBytes(currentSize);
  String get formattedMaxSize => _formatBytes(maxSize);

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}
