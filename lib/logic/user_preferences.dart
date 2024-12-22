import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const _keyHasSeenTutorial = 'hasSeenTutorial';
  static const _keyPreferredHardwareAcceleration = 'preferredHardwareAcceleration';
  static const _keyThemeMode = 'themeMode';

  final SharedPreferences _prefs;

  UserPreferences._(this._prefs);

  static Future<UserPreferences> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return UserPreferences._(prefs);
  }

  bool get hasSeenTutorial => _prefs.getBool(_keyHasSeenTutorial) ?? false;
  set hasSeenTutorial(bool value) => _prefs.setBool(_keyHasSeenTutorial, value);

  String get preferredHardwareAcceleration => _prefs.getString(_keyPreferredHardwareAcceleration) ?? 'none';
  set preferredHardwareAcceleration(String value) => _prefs.setString(_keyPreferredHardwareAcceleration, value);

  ThemeMode get themeMode {
    final themeString = _prefs.getString(_keyThemeMode) ?? 'system';
    switch (themeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
  set themeMode(ThemeMode value) {
    switch (value) {
      case ThemeMode.light:
        _prefs.setString(_keyThemeMode, 'light');
        break;
      case ThemeMode.dark:
        _prefs.setString(_keyThemeMode, 'dark');
        break;
      case ThemeMode.system:
        _prefs.setString(_keyThemeMode, 'system');
        break;
    }
  }

  String get selectedHardwareAcceleration {
    return _prefs.getString('selectedHardwareAcceleration') ?? 'none';
  }

  Future<void> setSelectedHardwareAcceleration(String method) async {
    await _prefs.setString('selectedHardwareAcceleration', method);
  }
}
