import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yaffuu/logic/ffmpeg.dart';
import 'package:yaffuu/logic/logger.dart';
import 'package:yaffuu/logic/user_preferences.dart';
import 'package:flutter/material.dart';

abstract class AppEvent {}

class StartApp extends AppEvent {}

abstract class AppState {}

class AppStart extends AppState {}

class AppStartLoading extends AppState {}

class AppStartSuccess extends AppState {
  final bool hasSeenTutorial;
  final FFmpegInfo ffmpegInfo;
  final String logFilePath;

  AppStartSuccess({
    required this.hasSeenTutorial,
    required this.ffmpegInfo,
    required this.logFilePath,
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

      emit(AppStartSuccess(
        hasSeenTutorial: hasSeenTutorial,
        ffmpegInfo: ffmpegInfo!,
        logFilePath: logFilePath,
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
    } catch (e) {
      emit(AppStartFailure(
        'An unknown error occurred: $e',
        AppErrorType.other,
      ));
    }
  }
}

enum ThemeEvent { light, dark, system }

class ThemeBloc extends Bloc<ThemeEvent, ThemeMode> {
  final UserPreferences _prefs;

  ThemeBloc(this._prefs) : super(_getInitialThemeMode(_prefs)) {
    on<ThemeEvent>((event, emit) {
      ThemeMode newMode;
      switch (event) {
        case ThemeEvent.light:
          newMode = ThemeMode.light;
          _prefs.themeMode = 'light';
          break;
        case ThemeEvent.dark:
          newMode = ThemeMode.dark;
          _prefs.themeMode = 'dark';
          break;
        case ThemeEvent.system:
          newMode = ThemeMode.system;
          _prefs.themeMode = 'system';
          break;
      }
      emit(newMode);
    });
  }

  static ThemeMode _getInitialThemeMode(UserPreferences prefs) {
    switch (prefs.themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}