import 'package:shared_preferences/shared_preferences.dart';
import '../base_preferences.dart';

/// UX memories preferences manager for tracking user experience states
class UxMemoriesPreferences extends BasePreferences {
  UxMemoriesPreferences(SharedPreferences prefs) : super('ux_memories', prefs);

  // Preference keys
  static const _hasSeenTutorialKey = PreferencesKey<bool>(
    key: 'has_seen_tutorial',
    defaultValue: false,
  );

  /// Check if the user has seen the tutorial
  Future<bool> getHasSeenTutorial() async {
    return getValue(_hasSeenTutorialKey);
  }

  /// Mark that the user has seen the tutorial
  Future<bool> setHasSeenTutorial(bool hasSeenTutorial) async {
    return setValue(_hasSeenTutorialKey, hasSeenTutorial);
  }
}
