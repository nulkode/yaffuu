import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yaffuu/logic/user_preferences.dart';

enum ThemeEvent { light, dark, system }

class ThemeBloc extends Bloc<ThemeEvent, ThemeMode> {
  final UserPreferences _prefs;

  ThemeBloc(this._prefs) : super(_prefs.themeMode) {
    on<ThemeEvent>((event, emit) {
      ThemeMode newMode;
      switch (event) {
        case ThemeEvent.light:
          newMode = ThemeMode.light;
          break;
        case ThemeEvent.dark:
          newMode = ThemeMode.dark;
          break;
        case ThemeEvent.system:
          newMode = ThemeMode.system;
          break;
      }
      _prefs.themeMode = newMode;
      emit(newMode);
    });
  }
}