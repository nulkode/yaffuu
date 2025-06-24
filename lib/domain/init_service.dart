import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:yaffuu/domain/output_files_service.dart';
import 'package:yaffuu/domain/logger.dart';
import 'package:yaffuu/domain/preferences/preferences_manager.dart';
import 'package:yaffuu/domain/constants/exception.dart';
import 'package:yaffuu/presentation/screens/common/error_screen.dart';
import 'package:yaffuu/main.dart';

/// Result object containing the outcome of app initialization
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

  /// Creates a successful initialization result
  AppInitializationResult.success()
      : isInitialized = true,
        errorCode = null,
        errorExtra = null,
        shouldShowTutorial = false;

  /// Creates a result indicating tutorial should be shown
  AppInitializationResult.tutorial()
      : isInitialized = false,
        errorCode = null,
        errorExtra = null,
        shouldShowTutorial = true;

  /// Creates an error result with error code and optional details
  AppInitializationResult.error(int this.errorCode, [String? extra])
      : isInitialized = false,
        errorExtra = extra,
        shouldShowTutorial = false;
}

/// Service responsible for initializing the entire application
class AppInitializationService {
  
  /// Main initialization method that orchestrates the entire app startup
  static Future<AppInitializationResult> initialize() async {
    try {
      await _initializeDependencies();
      
      final shouldShowTutorial = await _checkTutorialStatus();
      
      if (shouldShowTutorial) {
        return AppInitializationResult.tutorial();
      }
      
      await _finalizeInitialization();
      
      return AppInitializationResult.success();
      
    } on FFmpegNotCompatibleException {
      return AppInitializationResult.error(AppErrorType.ffmpegNotCompatible.id);
    } on FFmpegNotFoundException {
      return AppInitializationResult.error(4);
    } on FFmpegNotAccessibleException {
      return AppInitializationResult.error(AppErrorType.ffmpegNotAccessible.id);
    } on Exception catch (e) {
      logger.e('An unknown error occurred during initialization: $e');
      return AppInitializationResult.error(AppErrorType.other.id, e.toString());
    }
  }

  /// Initialize all dependencies and register them in the DI container
  static Future<void> _initializeDependencies() async {
    final preferencesManager = PreferencesManager();
    await preferencesManager.init();
    
    final (dataDir, outputFileManager) = await _setupDirectories();
    
    await _registerDependencies(preferencesManager, outputFileManager);
  }

  /// Check if the user has seen the tutorial and needs to see it
  static Future<bool> _checkTutorialStatus() async {
    final preferencesManager = getIt<PreferencesManager>();
    final hasSeenTutorial = await preferencesManager.uxMemories.getHasSeenTutorial();
    
    return !hasSeenTutorial;
  }

  /// Complete any remaining initialization steps
  static Future<void> _finalizeInitialization() async {
    // TODO: Initialize FFmpeg engine when queue service is ready
    // TODO: Setup any other services that depend on preferences
    
    logger.i('App initialization completed successfully');
  }

  /// Register all dependencies in the dependency injection container
  static Future<void> _registerDependencies(
    PreferencesManager preferencesManager,
    OutputFileManager outputFileManager,
  ) async {
    getIt.registerSingleton<PreferencesManager>(preferencesManager);
    
    getIt.registerSingleton<OutputFileManager>(outputFileManager);
    
    // TODO: Register other services as they are created
    // - QueueService
    // - FFmpegEngine (when ready)
    // - Any other core services
    
    logger.i('Dependencies registered successfully');
  }

  /// Setup application directories and file management
  static Future<(Directory, OutputFileManager)> _setupDirectories() async {
    final appSupportDir = await getApplicationSupportDirectory();
    final Directory dataDir = Directory('${appSupportDir.absolute.path}/data');

    final outputFileManager = OutputFileManager(
      dataDir: dataDir,
      maxSizeBytes: 2 * 1024 * 1024 * 1024,
      maxFiles: 150,
      cleanupStrategy: CleanupStrategy.oldestFirst,
    );

    await outputFileManager.initialize();
    
    logger.i('Directories setup completed: ${dataDir.path}');
    return (dataDir, outputFileManager);
  }
}
