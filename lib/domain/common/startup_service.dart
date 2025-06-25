import 'package:get_it/get_it.dart';
import 'package:yaffuu/domain/common/constants/exception.dart';
import 'package:yaffuu/domain/common/logger.dart';
import 'package:yaffuu/domain/preferences/preferences_manager.dart';
import 'package:yaffuu/presentation/screens/common/error_screen.dart';

final getIt = GetIt.instance;

/// Result object containing the outcome of the app's startup logic.
class AppInitializationResult {
  final bool isInitialized;
  final int? errorCode;
  final String? errorExtra;
  final bool shouldShowTutorial;

  AppInitializationResult({
    required this.isInitialized,
    this.errorCode,
    this.errorExtra,
    required this.shouldShowTutorial,
  });

  /// Creates a successful initialization result.
  AppInitializationResult.success()
      : isInitialized = true,
        errorCode = null,
        errorExtra = null,
        shouldShowTutorial = false;

  /// Creates a result indicating the tutorial should be shown.
  AppInitializationResult.tutorial()
      : isInitialized = false,
        errorCode = null,
        errorExtra = null,
        shouldShowTutorial = true;

  /// Creates an error result with an error code and optional details.
  AppInitializationResult.error(int this.errorCode, [String? extra])
      : isInitialized = false,
        errorExtra = extra,
        shouldShowTutorial = false;
}

/// Service responsible for running the application's startup logic.
class StartupService {
  /// Determines the initial state of the application.
  /// Assumes all dependencies have already been registered.
  static Future<AppInitializationResult> getInitialState() async {
    try {
      final preferencesManager = getIt<PreferencesManager>();
      final hasSeenTutorial =
          await preferencesManager.uxMemories.getHasSeenTutorial();

      if (!hasSeenTutorial) {
        logger.i(
            'User has not seen the tutorial. Navigating to tutorial screen.');
        return AppInitializationResult.tutorial();
      }

      logger.i('App initialization completed successfully.');
      return AppInitializationResult.success();
    } on FFmpegNotCompatibleException {
      return AppInitializationResult.error(AppErrorType.ffmpegNotCompatible.id);
    } on FFmpegNotAccessibleException {
      return AppInitializationResult.error(AppErrorType.ffmpegNotAccessible.id);
    } on Exception catch (e) {
      logger.e('An unknown error occurred during startup logic: $e');
      return AppInitializationResult.error(AppErrorType.other.id, e.toString());
    }
  }
}
