import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yaffuu/logic/user_preferences.dart';

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