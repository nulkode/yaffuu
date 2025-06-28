import 'package:shared_preferences/shared_preferences.dart';
import 'package:yaffuu/domain/preferences/general/settings_preferences.dart';
import 'package:yaffuu/domain/preferences/general/ux_memories_preferences.dart';
import 'package:yaffuu/domain/preferences/preferences_migration.dart';

/// Central manager for all app preferences
class PreferencesManager {
  SharedPreferences? _preferences;

  SettingsPreferences? _settings;
  UxMemoriesPreferences? _uxMemories;

  /// Initialize the preferences manager
  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();

    await PreferencesMigration.runMigrations();

    _settings = SettingsPreferences(_preferences!);
    _uxMemories = UxMemoriesPreferences(_preferences!);
  }

  /// Get settings preferences
  SettingsPreferences get settings {
    if (_settings == null) {
      throw StateError(
          'PreferencesManager not initialized. Call init() first.');
    }
    return _settings!;
  }

  /// Get UX memories preferences
  UxMemoriesPreferences get uxMemories {
    if (_uxMemories == null) {
      throw StateError(
          'PreferencesManager not initialized. Call init() first.');
    }
    return _uxMemories!;
  }

  /// Check if the manager is initialized
  bool get isInitialized => _preferences != null;

  /// Clear all preferences (for testing/debugging)
  Future<void> clearAll() async {
    if (_preferences == null) {
      throw StateError(
          'PreferencesManager not initialized. Call init() first.');
    }
    await _preferences!.clear();
  }
}
