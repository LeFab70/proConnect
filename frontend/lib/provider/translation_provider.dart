import 'package:flutter/material.dart';

enum AppLanguage { fr, en }

class TranslationProvider with ChangeNotifier {
  AppLanguage _language = AppLanguage.fr;

  AppLanguage get language => _language;
  String get languageCode => _language.name;
  Locale get locale => Locale(_language.name);

  final Map<String, Map<String, String>> _translations = {
    'fr': {
      'settings': 'Paramètres',
      'appearance': 'Apparence',
      'dark_mode': 'Mode sombre',
      'text_size': 'Taille du texte',
      'language': 'Langue',
      'notifications': 'Notifications',
      'sound': 'Son',
      'vibration': 'Vibration',
      'primary_color': 'Couleur principale',
      'account': 'Compte',
      'logout': 'Se déconnecter',

      'dashboard': 'Tableau de bord',
      'welcome': 'Bienvenue',
      'today_activity': 'Activité du jour',
      'today_medications': 'Médicaments du jour',
      'today_reminders': 'Rappels du jour',
      'today_appointments': 'Rendez-vous du jour',
      'see_details': 'Voir détails',
      'see_all': 'Tout voir',
      'no_medication': 'Aucun médicament ajouté',
      'no_reminder_today': 'Aucun rappel aujourd’hui',
      'no_appointment_today': 'Aucun rendez-vous aujourd’hui',
      'taken': 'Pris',
      'pending': 'En attente',
      'inactive': 'Inactif',
    },

    'en': {
      'settings': 'Settings',
      'appearance': 'Appearance',
      'dark_mode': 'Dark mode',
      'text_size': 'Text size',
      'language': 'Language',
      'notifications': 'Notifications',
      'sound': 'Sound',
      'vibration': 'Vibration',
      'primary_color': 'Primary color',
      'account': 'Account',
      'logout': 'Log out',

      'dashboard': 'Dashboard',
      'welcome': 'Welcome',
      'today_activity': "Today's activity",
      'today_medications': "Today's medications",
      'today_reminders': "Today's reminders",
      'today_appointments': "Today's appointments",
      'see_details': 'See details',
      'see_all': 'See all',
      'no_medication': 'No medication added',
      'no_reminder_today': 'No reminder today',
      'no_appointment_today': 'No appointment today',
      'taken': 'Taken',
      'pending': 'Pending',
      'inactive': 'Inactive',
    },
  };

  Future<void> setLanguage(AppLanguage lang) async {
    if (_language == lang) return;

    _language = lang;
    notifyListeners();
  }

  String tr(String key) {
    return _translations[_language.name]?[key] ?? key;
  }
}
