import 'package:flutter/material.dart';
import '../services/app_localizations.dart';

enum AppTheme { light, dark }

enum AppLanguage { fr, en }

class SettingsProvider extends ChangeNotifier {
  AppLanguage _language = AppLanguage.fr;

  AppLanguage get language => _language;
  String get languageCode => _language.name;
  Locale get locale => Locale(_language.name);

  Future<void> setLanguage(AppLanguage lang) async {
    if (_language == lang) return;

    _language = lang;
    await AppLocalizations.load(lang.name);

    notifyListeners();
  }

  String translate(String key) {
    return AppLocalizations.translate(key);
  }

  Future<String> t(String key) async {
    return AppLocalizations.translate(key);
  }

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  AppTheme get theme => _isDarkMode ? AppTheme.dark : AppTheme.light;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  double _fontSize = 1.0;
  double get fontSize => _fontSize;

  void setFontSize(double size) {
    _fontSize = size.clamp(0.8, 1.5);
    notifyListeners();
  }

  bool _sound = true;
  bool _vibration = true;

  bool get sound => _sound;
  bool get vibration => _vibration;

  void toggleSound() {
    _sound = !_sound;
    notifyListeners();
  }

  void toggleVibration() {
    _vibration = !_vibration;
    notifyListeners();
  }

  MaterialColor _primaryColor = Colors.blue;
  MaterialColor get primaryColor => _primaryColor;

  void changeColor(MaterialColor color) {
    _primaryColor = color;
    notifyListeners();
  }
}
