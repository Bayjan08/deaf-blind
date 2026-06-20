import 'package:shared_preferences/shared_preferences.dart';

/// Local key-value storage (tokens, progress cache, on-device calibration).
abstract class LocalStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

/// SharedPreferences-backed implementation. Used for the per-user neutral-face
/// calibration baseline, which must stay on the device (biometric) and is never
/// sent to the backend.
class SharedPrefsLocalStorage implements LocalStorage {
  @override
  Future<String?> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  @override
  Future<void> write(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }
}
