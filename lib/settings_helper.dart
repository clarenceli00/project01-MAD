import 'package:shared_preferences/shared_preferences.dart';

class SettingsHelper {
  final SharedPreferencesAsync prefs = SharedPreferencesAsync();

  // Save default target
  Future<void> saveDefaultTarget(int target) async {
    if (target < 1 || target > 7) {
      throw ArgumentError('Invalid target.');
    }

    await prefs.setInt('default_target', target);
  }

  // Read default target
  Future<int> getDefaultTarget() async {
    return await prefs.getInt('default_target') ?? 4;
  }

  // Save reduced motion
  Future<void> saveReducedMotion(bool value) async {
    await prefs.setBool('reduced_motion', value);
  }

  // Read reduced motion
  Future<bool> getReducedMotion() async {
    return await prefs.getBool('reduced_motion') ?? false;
  }
}
