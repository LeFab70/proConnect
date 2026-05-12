# ProConnectNB — Frontend (Flutter)

Application mobile de gestion de la santé pour aînés et proches aidants, développée en Flutter.

## Prérequis

- Flutter 3.x (stable channel)
- Dart 3.x
- Android Studio ou VS Code avec l'extension Flutter

## Configuration

1. Copier `lib/services/secrets.dart.example` → `lib/services/secrets.dart` et renseigner la clé API.
2. S'assurer que `baseUrl` dans `lib/services/api.dart` pointe vers le bon environnement.

## Lancer l'application

```bash
flutter pub get
flutter run
```

## Architecture

```
lib/
├── main.dart                  # Point d'entrée, routes, providers
├── models/                    # Modèles de données (Dart)
├── provider/                  # État global (Provider pattern)
│   ├── auth_provider.dart     # Session, profil utilisateur
│   ├── medication_provider.dart
│   ├── rappel_provider.dart
│   ├── partage_provider.dart
│   └── settings_provider.dart # Thème, langue, taille de police
├── screens/                   # Écrans de l'application
│   ├── auth/                  # Connexion, inscription, profil
│   ├── dashboard/             # Tableau de bord principal
│   ├── medications/           # Liste et historique des médicaments
│   ├── rappel/                # Rappels (notifications locales)
│   ├── appointments/          # Rendez-vous médicaux
│   ├── partage/               # Partage de suivi (aîné ↔ proche)
│   └── settings/              # Paramètres, aide, à propos
├── services/                  # Appels API, localisation, traduction
└── widgets/                   # Composants réutilisables
    ├── app_background.dart    # Fond dégradé adaptatif (mode sombre)
    └── tr_text.dart           # Widget de texte multilingue
```

## Fonctionnalités principales

- **Gestion des médicaments** : ajout, modification, historique de prise/oubli, remise à zéro automatique à minuit.
- **Rappels** : notifications locales programmées via `flutter_local_notifications`.
- **Rendez-vous médicaux** : suivi des consultations avec lieu et notes.
- **Partage de suivi** : un aîné peut inviter un proche aidant (lecture ou écriture).
- **Mode sombre** : bascule dans Paramètres → Préférences.
- **Multilingue** : français / anglais via `TrText` et `SettingsProvider`.

## Comptes de démonstration (seed)

| Rôle | Email | Mot de passe |
|------|-------|--------------|
| Aîné | david.roy@demo.local | Password123! |
| Aîné | joel.boudreau@demo.local | Password123! |
| Aîné | paul.wouatcha@demo.local | Password123! |
| Aîné | ghislain.duguay@demo.local | Password123! |
| Proche | kayleb.boudreau@demo.local | Password123! |
| Proche | fabrice.kouonang@demo.local | Password123! |
| Proche | perez.nguefack@demo.local | Password123! |
| Proche | grace.emmanuelle@demo.local | Password123! |
