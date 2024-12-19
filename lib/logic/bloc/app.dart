import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yaffuu/logic/classes/exception.dart';
import 'package:yaffuu/logic/parsing.dart';
import 'package:yaffuu/logic/logger.dart';
import 'package:yaffuu/logic/user_preferences.dart';

abstract class AppEvent {}

class StartApp extends AppEvent {}

abstract class AppState {}

class AppStart extends AppState {}

class AppStartLoading extends AppState {}

class AppStartSuccess extends AppState {
  final bool hasSeenTutorial;
  final FFmpegInfo ffmpegInfo;
  final Directory dataDir;
  final String logFilePath;

  AppStartSuccess({
    required this.hasSeenTutorial,
    required this.ffmpegInfo,
    required this.logFilePath,
    required this.dataDir,
  });
}

class AppStartFailure extends AppState {
  final String error;
  final AppErrorType errorType;

  AppStartFailure(this.error, this.errorType);
}

enum AppErrorType {
  ffmpegMissing,
  ffmpegOutdated,
  ffmpegNotAccessible,
  other,
}

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(AppStart()) {
    on<StartApp>(_onStartApp);
  }

  Future<void> _onStartApp(StartApp event, Emitter<AppState> emit) async {
    emit(AppStartLoading());
    try {
      final prefs = await UserPreferences.getInstance();
      final hasSeenTutorial = prefs.hasSeenTutorial;

      final ffmpegInfo = await checkFFmpegInstallation();
      final logFilePath = fileLogOutput.logFilePath;

      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final Directory dataDir = Directory('${appDocDir.path}/data');
      if (!await dataDir.exists()) {
        await dataDir.create(recursive: true);
      }

      emit(AppStartSuccess(
        hasSeenTutorial: hasSeenTutorial,
        ffmpegInfo: ffmpegInfo!,
        logFilePath: logFilePath,
        dataDir: dataDir,
      ));
    } on FFmpegNotFoundException {
      emit(AppStartFailure(
        'FFmpeg is not installed or not found in the system path.',
        AppErrorType.ffmpegMissing,
      ));
    } on FFmpegNotCompatibleException {
      emit(AppStartFailure(
        'FFmpeg version is not compatible.',
        AppErrorType.ffmpegOutdated,
      ));
    } on FFmpegNotAccessibleException {
      emit(AppStartFailure(
        'FFmpeg is not accessible.',
        AppErrorType.ffmpegNotAccessible,
      ));
    } on FileSystemException catch (e) {
      emit(AppStartFailure(
        'File system error: ${e.message}',
        AppErrorType.other,
      ));
    } catch (e) {
      emit(AppStartFailure(
        'An unknown error occurred: $e',
        AppErrorType.other,
      ));
    }
  }
}
