import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yaffuu/domain/common/constants/exception.dart';
import 'package:yaffuu/domain/common/logger.dart';
import 'package:yaffuu/infrastructure/ffmpeg/runtime/ffmpeg_info.dart';
import 'package:yaffuu/infrastructure/ffmpeg/media/media_analyzer.dart';
import 'package:yaffuu/domain/preferences/preferences_manager.dart';
import 'package:yaffuu/domain/queue/queue_service.dart';
import 'package:yaffuu/infrastructure/output_files_manager.dart';

final getIt = GetIt.instance;

/// Service responsible for setting up and registering all application dependencies.
class DependencyInjectionService {
  /// Creates instances of all services and registers them with the GetIt service locator.
  /// Throws exceptions if critical services like FFmpeg are not available.
  static Future<void> setup() async {
    try {
      final preferencesManager = PreferencesManager();
      await preferencesManager.init();
      getIt.registerSingleton<PreferencesManager>(preferencesManager);

      final outputFileManager = await _setupOutputFileManager();
      getIt.registerSingleton<OutputFileManager>(outputFileManager);

      final ffmpegInfoService = FFmpegInformationProvider();
      await ffmpegInfoService.getFFmpegInfo(); // Pre-cache FFmpeg info
      getIt.registerSingleton<FFmpegInformationProvider>(ffmpegInfoService);

      final mediaFileAnalyzer = MediaAnalyzer();
      getIt.registerSingleton<MediaAnalyzer>(mediaFileAnalyzer);

      final queueService = QueueService(outputFileManager);
      getIt.registerSingleton<QueueService>(queueService);

      logger.i('All dependencies registered successfully');
    } on FFmpegNotFoundException {
      logger.e('FFmpeg not found during dependency setup.');
      rethrow;
    } on Exception catch (e) {
      logger.e('An unknown error occurred during dependency setup: $e');
      rethrow;
    }
  }

  /// Sets up the directories and initializes the OutputFileManager.
  static Future<OutputFileManager> _setupOutputFileManager() async {
    final appSupportDir = await getApplicationSupportDirectory();
    final Directory dataDir = Directory(appSupportDir.absolute.path);

    final outputFileManager = OutputFileManager(
      dataDir: dataDir,
      maxSizeBytes: 2 * 1024 * 1024 * 1024, // 2GB
      maxFiles: 150,
      cleanupStrategy: CleanupStrategy.oldestFirst,
    );

    await outputFileManager.initialize();
    logger.i('Output file manager initialized at: ${dataDir.path}');
    return outputFileManager;
  }
}
