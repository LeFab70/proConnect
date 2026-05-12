import 'package:shared_preferences/shared_preferences.dart';

class DemoSyncService {
  static String _key(String medId) => 'demo_med_status_$medId';

  static Future<void> saveMedicationStatus({
    required String medId,
    required String status,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(medId), status);
  }

  static Future<String?> getMedicationStatus(String medId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key(medId));
  }
}