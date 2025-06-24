import 'package:shared_preferences/shared_preferences.dart';

/// A key for a preference with its type, default value, and key string.
class PreferencesKey<T> {
  const PreferencesKey({
    required this.key,
    required this.defaultValue,
  });

  /// The string key used to store/retrieve the preference
  final String key;
  
  /// The default value to return if the preference doesn't exist
  final T defaultValue;
  
  /// The type of the preference value
  Type get type => T;
}

/// Abstract base class for managing SharedPreferences with a base key prefix.
abstract class BasePreferences {
  BasePreferences(this.baseKey, this._prefs);

  /// The base key prefix for all preferences managed by this instance
  final String baseKey;

  /// The SharedPreferences instance
  final SharedPreferences _prefs;

  /// Build the full key by combining baseKey with the preference key
  String _buildKey(String key) => '$baseKey.$key';

  /// Get a value from preferences
  Future<T> getValue<T>(PreferencesKey<T> preferencesKey) async {
    final fullKey = _buildKey(preferencesKey.key);

    if (T == String) {
      return _prefs.getString(fullKey) as T? ?? preferencesKey.defaultValue;
    } else if (T == int) {
      return _prefs.getInt(fullKey) as T? ?? preferencesKey.defaultValue;
    } else if (T == double) {
      return _prefs.getDouble(fullKey) as T? ?? preferencesKey.defaultValue;
    } else if (T == bool) {
      return _prefs.getBool(fullKey) as T? ?? preferencesKey.defaultValue;
    } else if (T == List<String>) {
      return _prefs.getStringList(fullKey) as T? ?? preferencesKey.defaultValue;
    } else {
      throw UnsupportedError('Type $T is not supported');
    }
  }

  /// Set a value in preferences
  Future<bool> setValue<T>(PreferencesKey<T> preferencesKey, T value) async {
    final fullKey = _buildKey(preferencesKey.key);

    if (T == String) {
      return _prefs.setString(fullKey, value as String);
    } else if (T == int) {
      return _prefs.setInt(fullKey, value as int);
    } else if (T == double) {
      return _prefs.setDouble(fullKey, value as double);
    } else if (T == bool) {
      return _prefs.setBool(fullKey, value as bool);
    } else if (T == List<String>) {
      return _prefs.setStringList(fullKey, value as List<String>);
    } else {
      throw UnsupportedError('Type $T is not supported');
    }
  }

  /// Remove a preference
  Future<bool> removeValue(PreferencesKey preferencesKey) async {
    final fullKey = _buildKey(preferencesKey.key);
    return _prefs.remove(fullKey);
  }

  /// Check if a preference exists
  Future<bool> hasKey(PreferencesKey preferencesKey) async {
    final fullKey = _buildKey(preferencesKey.key);
    return _prefs.containsKey(fullKey);
  }

  /// Clear all preferences with this baseKey prefix
  Future<bool> clearAll() async {
    final keys = _prefs.getKeys().where((key) => key.startsWith('$baseKey.')).toList();
    
    bool success = true;
    for (final key in keys) {
      success &= await _prefs.remove(key);
    }
    return success;
  }
}