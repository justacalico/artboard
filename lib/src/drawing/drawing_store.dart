import 'package:shared_preferences/shared_preferences.dart';

/// Persists the drawing as a JSON string on the device.
class DrawingStore {
  static const _key = 'artboard.drawing.v1';

  Future<void> save(String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json);
  }

  Future<String?> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }
}
