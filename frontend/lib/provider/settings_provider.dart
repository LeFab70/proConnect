import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/app_localizations.dart';

enum AppTheme { light, dark }

enum AppLanguage { fr, en }

class SettingsProvider extends ChangeNotifier {
  // =========================
  // LANGUE
  // =========================
  AppLanguage _language = AppLanguage.fr;

  AppLanguage get language => _language;
  String get languageCode => _language.name;
  Locale get locale => Locale(_language.name);

  Future<void> setLanguage(AppLanguage lang) async {
    if (_language == lang) return;

    _language = lang;
    await AppLocalizations.load(lang.name);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("language", lang.name);

    notifyListeners();
  }

  String translate(String key) {
    return AppLocalizations.translate(key);
  }

  // =========================
  // THEME
  // =========================
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;
  AppTheme get theme => _isDarkMode ? AppTheme.dark : AppTheme.light;

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("darkMode", _isDarkMode);

    notifyListeners();
  }

  // =========================
  // FONT SIZE
  // =========================
  double _fontSize = 1.0;

  double get fontSize => _fontSize;

  Future<void> setFontSize(double size) async {
    _fontSize = size.clamp(0.8, 1.5);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble("fontSize", _fontSize);

    notifyListeners();
  }

  // =========================
  // SON & VIBRATION
  // =========================
  bool _sound = true;
  bool _vibration = true;

  bool get sound => _sound;
  bool get vibration => _vibration;

  Future<void> toggleSound() async {
    _sound = !_sound;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("sound", _sound);

    notifyListeners();
  }

  Future<void> toggleVibration() async {
    _vibration = !_vibration;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("vibration", _vibration);

    notifyListeners();
  }

  // =========================
  // COULEUR
  // =========================
  MaterialColor _primaryColor = Colors.blue;

  MaterialColor get primaryColor => _primaryColor;

  Future<void> changeColor(MaterialColor color) async {
    _primaryColor = color;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("primaryColor", color.toARGB32());

    notifyListeners();
  }

  // =========================
  // LOAD SETTINGS (IMPORTANT)
  // =========================
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // LANGUE
    final lang = prefs.getString("language");
    if (lang != null) {
      _language = AppLanguage.values.firstWhere(
        (e) => e.name == lang,
        orElse: () => AppLanguage.fr,
      );
      await AppLocalizations.load(_language.name);
    }

    // THEME
    _isDarkMode = prefs.getBool("darkMode") ?? false;

    // FONT
    _fontSize = prefs.getDouble("fontSize") ?? 1.0;

    // SON
    _sound = prefs.getBool("sound") ?? true;

    // VIBRATION
    _vibration = prefs.getBool("vibration") ?? true;

    notifyListeners();
  }
}
