import 'dart:convert';
import 'package:flutter/services.dart';

class AppLocalizations {
  static Map<String, String> _localized = {};
  static String _currentLang = 'fr';

  static Future<void> load(String lang) async {
    _currentLang = lang;

    try {
      final jsonString =
          await rootBundle.loadString('assets/lang/$lang.json');

      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      _localized = jsonMap.map(
        (key, value) => MapEntry(key, value.toString()),
      );

      print("✅ Langue chargée : $lang");
    } catch (e) {
      _localized = {};
      print("⚠️ Erreur chargement langue: $e");
    }
  }

  static String tr(String key) {
    if (_localized.isEmpty) {
      return key;
    }

    return _localized[key] ?? key;
  }

  static String translate(String key) {
    return tr(key);
  }

  static String get currentLanguage => _currentLang;
}