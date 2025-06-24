import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:yaffuu/domain/output_files_service.dart';
import 'package:yaffuu/domain/logger.dart';
import 'package:yaffuu/logic/user_preferences.dart';
import 'package:yaffuu/ffmpeg/engines/base_engine.dart';
import 'package:yaffuu/domain/constants/exception.dart';
import 'package:yaffuu/domain/ffmpeg/engine_provider.dart';
import 'package:yaffuu/domain/di_service.dart';
import 'package:yaffuu/presentation/screens/common/error_screen.dart';
import 'package:yaffuu/main.dart';

class AppInitializationResult {
  final bool isInitialized;
  final int? errorCode;
  final String? errorExtra;
  final bool shouldShowTutorial;
  final FFmpegEngine? engine;

  AppInitializationResult({
    required this.isInitialized,
    this.errorCode,
    this.errorExtra,
    required this.shouldShowTutorial,
    this.engine,
  });

  AppInitializationResult.success(FFmpegEngine this.engine)
      : isInitialized = true,
        errorCode = null,
        errorExtra = null,
        shouldShowTutorial = false;

  AppInitializationResult.tutorial()
      : isInitialized = false,
        errorCode = null,
        errorExtra = null,
        shouldShowTutorial = true,
        engine = null;

  AppInitializationResult.error(int this.errorCode, [String? extra])
      : isInitialized = false,
        errorExtra = extra,
        shouldShowTutorial = false,
        engine = null;
}

class AppInitializationService {
  static Future<AppInitializationResult> initialize() async {
    try {
      final prefs = await UserPreferences.getInstance();

      final engine = await getIt<EngineProvider>()
          .createEngine(prefs.preferredHardwareAcceleration); // TODO: will be passed to the queue service

      // ignore: unused_local_variable
      final hasSeenTutorial = prefs.hasSeenTutorial;

      final (dataDir, outputFileManager) = await setupDirectories();

      DependencyInjectionService.registerDependencies(
        outputFileManager,
      );

      // ignore: dead_code
      if (/* !hasSeenTutorial */ false) {
        // TODO: build tutorial
        return AppInitializationResult.tutorial();
      } else {
        return AppInitializationResult.success(engine);
      }
    } on FFmpegNotCompatibleException {
      return AppInitializationResult.error(AppErrorType.ffmpegNotCompatible.id);
    } on FFmpegNotFoundException {
      return AppInitializationResult.error(4);
    } on FFmpegNotAccessibleException {
      return AppInitializationResult.error(AppErrorType.ffmpegNotAccessible.id);
    } on Exception catch (e) {
      logger.e('An unknown error occurred: $e');
      return AppInitializationResult.error(AppErrorType.other.id, e.toString());
    }
  }

  static Future<(Directory, OutputFileManager)> setupDirectories() async {
    final Directory dataDir = Directory(
        '${(await getApplicationSupportDirectory()).absolute.path}/data');

    final outputFileManager = OutputFileManager(
      dataDir: dataDir,
      maxSizeBytes: 2 * 1024 * 1024 * 1024, // 2GB limit
      maxFiles: 150, // Maximum 150 files
      cleanupStrategy: CleanupStrategy.oldestFirst,
    );

    await outputFileManager.initialize();

    return (dataDir, outputFileManager);
  }
}
