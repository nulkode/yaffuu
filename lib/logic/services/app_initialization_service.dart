import 'package:yaffuu/logic/ffmpeg.dart';
import 'package:yaffuu/logic/logger.dart';
import 'package:yaffuu/logic/user_preferences.dart';
import 'package:yaffuu/logic/managers/managers.dart';
import 'package:yaffuu/logic/classes/exception.dart';
import 'package:yaffuu/logic/models/app_info.dart';
import 'package:yaffuu/logic/services/directory_service.dart';
import 'package:yaffuu/logic/services/ffmpeg_manager_service.dart';
import 'package:yaffuu/logic/services/dependency_injection_service.dart';
import 'package:yaffuu/ui/screens/error.dart';

class AppInitializationResult {
  final bool isInitialized;
  final int? errorCode;
  final String? errorExtra;
  final bool shouldShowTutorial;
  final BaseFFmpegManager? manager;

  AppInitializationResult({
    required this.isInitialized,
    this.errorCode,
    this.errorExtra,
    required this.shouldShowTutorial,
    this.manager,
  });

  AppInitializationResult.success(BaseFFmpegManager manager) :
    isInitialized = true,
    errorCode = null,
    errorExtra = null,
    shouldShowTutorial = false,
    manager = manager;

  AppInitializationResult.tutorial() :
    isInitialized = false,
    errorCode = null,
    errorExtra = null,
    shouldShowTutorial = true,
    manager = null;

  AppInitializationResult.error(int errorCode, [String? extra]) :
    isInitialized = false,
    errorCode = errorCode,
    errorExtra = extra,
    shouldShowTutorial = false,
    manager = null;
}

class AppInitializationService {
  static Future<AppInitializationResult> initialize() async {
    try {
      final prefs = await UserPreferences.getInstance();
      // ignore: unused_local_variable
      final hasSeenTutorial = prefs.hasSeenTutorial;

      final ffmpegInfo = await FFService.getFFmpegInfo();
      final logFilePath = fileLogOutput.logFilePath;
      
      final (dataDir, outputFileManager) = await DirectoryService.setupDirectories();

      final appInfo = AppInfo(
        logPathInfo: logFilePath,
        ffmpegInfo: ffmpegInfo,
        dataDir: dataDir,
        outputFileManager: outputFileManager,
      );

      DependencyInjectionService.registerAppInfo(appInfo);

      final manager = await FFmpegManagerService.createManager(
        ffmpegInfo, 
        prefs.preferredHardwareAcceleration
      );

      // ignore: dead_code
      if (/* !hasSeenTutorial */ false) {
        // TODO: build tutorial
        return AppInitializationResult.tutorial();
      } else {
        return AppInitializationResult.success(manager);
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
}
