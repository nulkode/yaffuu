import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yaffuu/domain/preferences/preferences_manager.dart';
import 'package:yaffuu/main.dart';

enum ThemeEvent { light, dark, system }

class ThemeBloc extends Bloc<ThemeEvent, ThemeMode> {
  late final PreferencesManager _preferencesManager;

  ThemeBloc() : super(ThemeMode.system) {
    _preferencesManager = getIt<PreferencesManager>();
    
    on<ThemeEvent>((event, emit) async {
      late ThemeMode newTheme;
      
      switch (event) {
        case ThemeEvent.light:
          newTheme = ThemeMode.light;
          break;
        case ThemeEvent.dark:
          newTheme = ThemeMode.dark;
          break;
        case ThemeEvent.system:
          newTheme = ThemeMode.system;
          break;
      }
      
      await _preferencesManager.settings.setThemeMode(newTheme);
      emit(newTheme);
    });
    
    _loadInitialTheme();
  }

  /// Load the initial theme from preferences
  void _loadInitialTheme() async {
    final currentTheme = await _preferencesManager.settings.getThemeMode();
    add(_getEventForTheme(currentTheme));
  }

  /// Convert ThemeMode to ThemeEvent
  ThemeEvent _getEventForTheme(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return ThemeEvent.light;
      case ThemeMode.dark:
        return ThemeEvent.dark;
      case ThemeMode.system:
        return ThemeEvent.system;
    }
  }
}
