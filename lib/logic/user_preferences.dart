import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const _keyHasSeenTutorial = 'hasSeenTutorial';
  static const _keyPreferredHardwareAcceleration = 'preferredHardwareAcceleration';
  static const _keyIsDarkTheme = 'isDarkTheme';

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

  bool get isDarkTheme => _prefs.getBool(_keyIsDarkTheme) ?? false;
  set isDarkTheme(bool value) => _prefs.setBool(_keyIsDarkTheme, value);

  String? get selectedHardwareAcceleration {
    return _prefs.getString('selectedHardwareAcceleration');
  }

  Future<void> setSelectedHardwareAcceleration(String method) async {
    await _prefs.setString('selectedHardwareAcceleration', method);
  }
}
