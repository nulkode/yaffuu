import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../classes/compression_option.dart';

class CompressionPreferencesManager {
  static const String _recentOptionsKey = 'recent_compression_options';
  static const String _customOptionsKey = 'custom_compression_options';
  static const String _lastSelectedKey = 'last_selected_compression';

  static const int maxRecentOptions = 5;
  static const int maxCustomOptions = 10;

  static Future<List<CompressionOption>> getRecentOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_recentOptionsKey) ?? [];

    return jsonList.map((jsonStr) {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return CompressionOption.fromMap(map);
    }).toList();
  }

  static Future<void> addRecentOption(CompressionOption option) async {
    if (option.isCustom) return;

    final prefs = await SharedPreferences.getInstance();
    final recent = await getRecentOptions();

    recent.removeWhere((item) => item.platform == option.platform);

    recent.insert(0, option);

    if (recent.length > maxRecentOptions) {
      recent.removeRange(maxRecentOptions, recent.length);
    }

    final jsonList = recent.map((item) => jsonEncode(item.toMap())).toList();
    await prefs.setStringList(_recentOptionsKey, jsonList);
  }

  static Future<List<CustomSizeOption>> getCustomOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_customOptionsKey) ?? [];

    return jsonList.map((jsonStr) {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return CustomSizeOption.fromMap(map);
    }).toList();
  }

  static Future<void> addCustomOption(CustomSizeOption option) async {
    final prefs = await SharedPreferences.getInstance();
    final custom = await getCustomOptions();

    custom.removeWhere(
        (item) => item.size == option.size && item.unit == option.unit);

    custom.insert(0, option);

    if (custom.length > maxCustomOptions) {
      custom.removeRange(maxCustomOptions, custom.length);
    }

    final jsonList = custom.map((item) => jsonEncode(item.toMap())).toList();
    await prefs.setStringList(_customOptionsKey, jsonList);
  }

  static Future<void> removeCustomOption(CustomSizeOption option) async {
    final prefs = await SharedPreferences.getInstance();
    final custom = await getCustomOptions();

    custom.removeWhere((item) =>
        item.size == option.size &&
        item.unit == option.unit &&
        item.createdAt == option.createdAt);

    final jsonList = custom.map((item) => jsonEncode(item.toMap())).toList();
    await prefs.setStringList(_customOptionsKey, jsonList);
  }

  static Future<CompressionOption?> getLastSelectedOption() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_lastSelectedKey);

    if (jsonStr == null) return null;

    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return CompressionOption.fromMap(map);
    } catch (e) {
      return null;
    }
  }

  static Future<void> setLastSelectedOption(CompressionOption? option) async {
    final prefs = await SharedPreferences.getInstance();

    if (option == null) {
      await prefs.remove(_lastSelectedKey);
    } else {
      final jsonStr = jsonEncode(option.toMap());
      await prefs.setString(_lastSelectedKey, jsonStr);
    }
  }

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentOptionsKey);
    await prefs.remove(_customOptionsKey);
    await prefs.remove(_lastSelectedKey);
  }
}
