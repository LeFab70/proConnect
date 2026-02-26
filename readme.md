# 📦 Nom du Projet
*Application Full‑Stack : Flutter + ASP.NET Core + PostgreSQL*

## 🚀 Aperçu
Ce projet est une application full‑stack composée de :
- Flutter pour le frontend (mobile)
- ASP.NET Core pour l’API backend
- PostgreSQL (hébergé sur Neon)
- VS Code comme environnement principal

L’objectif est de fournir une architecture propre, simple à cloner, lancer et faire évoluer pour tous les membres de l’équipe.

## 🏗️ Structure du Projet
/frontend        → Application Flutter
/backend         → API ASP.NET Core
/infrastructure  → Scripts SQL, migrations, outils DB

## 🔧 Prérequis

### Frontend (Flutter)
- Flutter SDK (version stable)
- Dart (inclus avec Flutter)

### Backend (ASP.NET Core)
- .NET 8 SDK
- Support C# 12

### Base de données
- Compte Neon (PostgreSQL cloud)

### Outils recommandés
- VS Code
- Git

## 🛠️ Installation

### 1. Cloner le dépôt
git clone https://github.com/Kayleb-Aubie/ProConnectNB.git
cd ProConnectNB

# 🖥️ Configuration de fichiers

### 1. Configurer les variables d’environnement pour prevenir le spam sur le serveur Azure (future)
Créer le fichier :
frontend/lib/secrets.dart

class Secrets
{
  static const String apiKey = "";
}

# 📱 Installation du Frontend (Flutter)

### 1. Aller dans le dossier frontend
cd frontend

### 2. Installer les dépendances
flutter pub get

### 3. Lancer l’application
flutter run

# 🔐 Variables d’Environnement
Chaque membre doit créer :
- secrets.dart (ApiKey)

Ne jamais commit ces fichiers.

# 🧠 Notes pour l’Équipe
- Ne jamais commit de secrets ou fichiers d’environnement
- Ne jamais commit les dossiers de build
- Respecter le .gitignore
- Garder backend et frontend synchronisés lors de modifications des modèles API