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

## 🖥️ Configuration (Backend)

### Variables d’environnement requises
Le backend lit la connexion DB et l’auth JWT depuis des variables d’environnement.

- **`DefaultConnection`**: connection string PostgreSQL (Neon)
- **`JWT__Key`**: clé symétrique (min 32 chars recommandé)
- **`JWT__Issuer`**: ex `ProConnectNB` (optionnel)
- **`JWT__Audience`**: ex `ProConnectNB` (optionnel)
- **`JWT__ExpiresMinutes`**: ex `120` (optionnel)
- **`SEED_DATA`**: mettre `true` pour insérer des données de démonstration au démarrage (après migrations)
- **`SEED_PASSWORD`**: mot de passe des users seed (défaut `Password123!`)

### Email reset password (optionnel)
- **`SMTP__HOST`**, **`SMTP__PORT`**, **`SMTP__USER`**, **`SMTP__PASS`**, **`SMTP__FROM`**
- **`RESET_PASSWORD__BASE_URL`**: URL front pour construire le lien de reset (ex: `http://localhost:3000/reset-password`)

### IA (suggestions d’activités communautaires)
Endpoint:
- `POST /api/activites/suggestions` (protégé) → renvoie des activités suggérées.

Variables:
- **`AI_PROVIDER`**: `mock` (défaut) ou `huggingface`
- **`HF_TOKEN`**: token HuggingFace (si `AI_PROVIDER=huggingface`)
- **`HF_MODEL`**: modèle HF (optionnel)
- **`HF_ENDPOINT`**: endpoint d’inférence (optionnel). Par défaut: `https://api-inference.huggingface.co/models/<HF_MODEL>`

### Lancer le backend
Dans un terminal:

```bash
cd backend
dotnet restore
dotnet run
```

Swagger (en dev): `http://localhost:5xxx/swagger`

### Obtenir un JWT (dev)
Utilise `POST /api/auth/login` (ou `POST /api/auth/register`) puis dans Swagger bouton **Authorize** → `Bearer <token>`.

Endpoint utile pour vérifier le token:
- `GET /api/auth/me` (protégé) retourne `userId/email/roles` depuis le JWT.

### 🔐 Endpoints protégés
- La majorité des endpoints API sont en **`[Authorize]`** (token obligatoire).
- Les opérations d’écriture (POST/PUT/DELETE) sont généralement **AdminOnly** (rôle dans le JWT).

### 🧬 Héritage (User abstrait)
- `User` est une **classe abstraite**.
- `Aine` et `ProcheAidant` **héritent** de `User` (sans dupliquer les champs).
- Mapping EF Core en **TPH**: une seule table `users` avec une colonne `type` (discriminateur).

### Minimal API (MapGet/MapPost/MapPut/MapDelete)
Le backend utilise maintenant les **Minimal APIs** (route groups) au lieu des controllers MVC.

### 🧬 Migrations EF Core
Le backend applique automatiquement les migrations au démarrage.

Pour générer une migration:

```bash
cd backend
dotnet ef migrations add Initial
```

Pour appliquer manuellement:

```bash
cd backend
dotnet ef database update
```

### 🌱 Seed (données de démo)
Si `SEED_DATA=true`, le backend insère des données de démonstration (Fabrice/Kayleb/Perez/Grace + aîné + proche aidant + médicament + rendez-vous + rappel) au démarrage.

# 📱 Installation du Frontend (Flutter)

### 1. Aller dans le dossier frontend
cd frontend

### 2. Installer les dépendances
flutter pub get

### 3. Lancer l’application
flutter run

# 🧠 Notes pour l’Équipe
- Ne jamais commit de secrets ou fichiers d’environnement
- Ne jamais commit les dossiers de build
- Respecter le .gitignore
- Garder backend et frontend synchronisés lors de modifications des modèles API

## 👥 Développeurs du projet
- Kayleb
- Grace
- Perez
- Fabrice