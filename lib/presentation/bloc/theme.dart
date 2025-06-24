import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yaffuu/logic/user_preferences.dart';

enum ThemeEvent { light, dark, system }

class ThemeBloc extends Bloc<ThemeEvent, ThemeMode> {
  ThemeBloc(UserPreferences userPreferences)
      : super(userPreferences.themeMode) {
    on<ThemeEvent>((event, emit) {
      switch (event) {
        case ThemeEvent.light:
          userPreferences.themeMode = ThemeMode.light;
          emit(ThemeMode.light);
          break;
        case ThemeEvent.dark:
          userPreferences.themeMode = ThemeMode.dark;
          emit(ThemeMode.dark);
          break;
        case ThemeEvent.system:
          userPreferences.themeMode = ThemeMode.system;
          emit(ThemeMode.system);
          break;
      }
    });
  }
}
