# ProConnectNB

Application full-stack : **Flutter** (mobile), **ASP.NET Core 8** (API Minimal), **PostgreSQL** (ex. Neon).

## Structure

| Dossier | Rôle |
|---------|------|
| `frontend/` | Application Flutter |
| `backend/` | API, EF Core, migrations dans `backend/Migrations/` |

## Prérequis

- Flutter (stable) + Dart
- .NET 8 SDK
- Instance PostgreSQL (connection string prête)

## Backend

### Variables d’environnement

| Variable | Rôle |
|----------|------|
| `DefaultConnection` | Chaîne PostgreSQL |
| `JWT__Key` | Clé symétrique JWT (≥ 32 caractères recommandé) |
| `JWT__Issuer`, `JWT__Audience`, `JWT__ExpiresMinutes` | Optionnel |
| `SEED_DATA` | `true` pour insérer les données de démo au démarrage |
| `SEED_PASSWORD` | Mot de passe des comptes seed (défaut `Password123!`) |
| `SMTP__HOST`, `SMTP__PORT`, `SMTP__USER`, `SMTP__PASS`, `SMTP__FROM` | Envoi d’e-mails (reset mot de passe), optionnel |
| `RESET_PASSWORD__BASE_URL` | URL front pour le lien de réinitialisation |
| `AI_PROVIDER` | `mock` (défaut) ou `huggingface` |
| `HF_TOKEN`, `HF_MODEL`, `HF_ENDPOINT` | Si `AI_PROVIDER=huggingface` |

### Lancer l’API

```bash
cd backend
dotnet restore
dotnet run
```

Swagger en développement : URL affichée dans la console (souvent `http://localhost:5xxx/swagger`).

### Auth

- `POST /api/auth/register`, `POST /api/auth/login` → JWT.
- Swagger : **Authorize** → `Bearer <token>`.
- `GET /api/auth/me` : profil décodé du token.

La plupart des routes sont sous `[Authorize]` ; les écritures sensibles sont souvent `AdminOnly`.

### Modèle utilisateur (EF TPH)

`User` abstrait ; `Aine`, `ProcheAidant`, `StandardUser` dans la table `users` avec discriminateur `type`.

### Médicaments et listes

- `is_deleted` : suppression **logique** ; `GET /api/medicaments` ne renvoie **que** les non supprimés.
- `is_active` : à utiliser côté client pour activer ou non les **notifications** liées au médicament.
- `DELETE /api/medicaments/{id}` : passe `is_deleted` à `true`.

### Rappels (prise ou RDV)

- Champs principaux : `dateDebut`, `heureDebut`, `minutesAvantRappel` (ex. 15 = notifier 15 minutes **avant**).
- `type` : `Medicament` (+ `medicamentId`) ou `RendezVousMedical` (+ `rendezVousMedicalId`).
- Réponses enrichies : `dateHeurePrise`, `dateHeureNotification` (calculées côté API).

### Migrations EF Core

Les migrations sont appliquées **au démarrage** (`MigrateAsync`).

Pour en ajouter une à la main :

```bash
cd backend
dotnet ef migrations add NomMigration
dotnet ef database update
```

Dernière migration notable : `MedicamentFlagsAndRappelSchedule` (colonnes médicament + schéma rappel).

### Seed (`SEED_DATA=true`)

Comptes de démo (Fabrice, Kayleb, Perez, Grace), un aîné, un proche aidant, un médicament, un rendez-vous, un rappel exemple.

## Frontend (Flutter)

```bash
cd frontend
flutter pub get
flutter run
```

Configurer l’URL de l’API dans `lib/api.dart` (`baseUrl`).

## Bonnes pratiques équipe

- Ne pas committer de secrets ni de fichiers d’environnement locaux.
- Respecter le `.gitignore` (pas de `bin/`, `obj/`, etc.).
- Aligner les DTOs Flutter lorsque l’API change.

## Contributeurs

Kayleb, Grace, Perez, Fabrice
