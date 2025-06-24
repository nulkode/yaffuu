import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../base_preferences.dart';

/// Hardware acceleration options for video processing
enum HwAccel {
  none('none'),
  cuda('cuda'),
  qsv('qsv'); // QuickSync Video (Intel)

  const HwAccel(this.value);
  final String value;

  static HwAccel fromString(String value) {
    return HwAccel.values.firstWhere(
      (hwAccel) => hwAccel.value == value,
      orElse: () => HwAccel.none,
    );
  }
}

/// Settings preferences manager
class SettingsPreferences extends BasePreferences {
  SettingsPreferences(SharedPreferences prefs) : super('settings', prefs);

  // Preference keys
  static const _themeKey = PreferencesKey<int>(
    key: 'theme_mode',
    defaultValue: 0, // ThemeMode.system.index
  );

  static const _hwAccelKey = PreferencesKey<String>(
    key: 'hw_accel',
    defaultValue: 'none',
  );

  /// Get the current theme mode
  Future<ThemeMode> getThemeMode() async {
    final index = await getValue(_themeKey);
    return ThemeMode.values[index];
  }

  /// Set the theme mode
  Future<bool> setThemeMode(ThemeMode themeMode) async {
    return setValue(_themeKey, themeMode.index);
  }

  /// Get the current hardware acceleration setting
  Future<HwAccel> getHwAccel() async {
    final value = await getValue(_hwAccelKey);
    return HwAccel.fromString(value);
  }

  /// Set the hardware acceleration setting
  Future<bool> setHwAccel(HwAccel hwAccel) async {
    return setValue(_hwAccelKey, hwAccel.value);
  }
}