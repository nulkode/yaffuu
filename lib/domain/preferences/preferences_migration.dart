import 'package:shared_preferences/shared_preferences.dart';

/// Manages preferences migrations when the app structure changes
class PreferencesMigration {
  static const String _migrationVersionKey = 'preferences_migration_version';
  static const int _currentMigrationVersion = 1;

  /// Run all necessary migrations
  static Future<void> runMigrations() async {
    final prefs = await SharedPreferences.getInstance();
    final currentVersion = prefs.getInt(_migrationVersionKey) ?? 0;

    if (currentVersion < _currentMigrationVersion) {
      await _performMigrations(prefs, currentVersion);
      await prefs.setInt(_migrationVersionKey, _currentMigrationVersion);
    }
  }

  /// Perform migrations from the current version to the latest
  static Future<void> _performMigrations(
    SharedPreferences prefs,
    int fromVersion,
  ) async {
    for (int version = fromVersion + 1; version <= _currentMigrationVersion; version++) {
      await _migrateToVersion(prefs, version);
    }
  }

  /// Migrate to a specific version
  static Future<void> _migrateToVersion(
    SharedPreferences prefs,
    int targetVersion,
  ) async {
    switch (targetVersion) {
      case 1:
        await _migrateToVersion1(prefs);
        break;
      // Add future migration cases here
      // case 2:
      //   await _migrateToVersion2(prefs);
      //   break;
      default:
        throw UnsupportedError('Migration to version $targetVersion is not supported');
    }
  }

  /// Migration to version 1 (baseline - no actual migration needed)
  static Future<void> _migrateToVersion1(SharedPreferences prefs) async {
    // This is the baseline version, no migration needed
    // Future migrations will be added as new methods
  }

  /// Get the current migration version
  static Future<int> getCurrentVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_migrationVersionKey) ?? 0;
  }

  /// Reset all preferences (for debugging/testing purposes)
  static Future<void> resetAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}