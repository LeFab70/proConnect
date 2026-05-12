using backend.Models;
using Microsoft.EntityFrameworkCore;

namespace backend.Infrastructure;

/// <summary>Migrations au démarrage ; seed si <c>SEED_DATA=true</c>.</summary>
public static class SeedData
{
    public static async Task ApplyMigrationsAndSeedAsync(IServiceProvider services, CancellationToken ct = default)
    {
        using var scope = services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var hasher = new Microsoft.AspNetCore.Identity.PasswordHasher<User>();

        await db.Database.MigrateAsync(ct);

        var seedVar = Environment.GetEnvironmentVariable("SEED_DATA");
        var seedEnabled = string.Equals(seedVar, "true", StringComparison.OrdinalIgnoreCase) ||
                          seedVar == "1" ||
                          string.Equals(seedVar, "yes", StringComparison.OrdinalIgnoreCase);
        if (!seedEnabled) return;

        // Réinitialisation complète pour la démo.
        await db.Database.ExecuteSqlRawAsync("""
            DELETE FROM rappels;
            DELETE FROM partages_suivi;
            DELETE FROM medicaments;
            DELETE FROM rendez_vous_medicaux;
            DELETE FROM users;
            """, ct);

        var plain = Environment.GetEnvironmentVariable("SEED_PASSWORD") ?? "Password123!";

        // ── Aînés ───────────────────────────────────────────────────────────────

        var aine1 = new Aine
        {
            Nom = "Roy",
            Prenom = "David",
            Telephone = "506-555-0101",
            Email = "david.roy@demo.local",
            PasswordHash = "temp",
            DateNaissance = new DateOnly(1942, 10, 3),
            Docteur = "Dr. Robichaud",
            NumeroTelephoneDocteur = "506-555-0199",
            Adresse = new Adresse { Numero = "9", Rue = "Rue du Parc", Ville = "Riverview", Province = "NB", CodePostal = "E1B2C2" }
        };

        var aine2 = new Aine
        {
            Nom = "Boudreau",
            Prenom = "Joel",
            Telephone = "506-555-0102",
            Email = "joel.boudreau@demo.local",
            PasswordHash = "temp",
            DateNaissance = new DateOnly(1948, 3, 15),
            Docteur = "Dr. Landry",
            NumeroTelephoneDocteur = "506-555-0198",
            Adresse = new Adresse { Numero = "45", Rue = "Chemin Coverdale", Ville = "Moncton", Province = "NB", CodePostal = "E1C3A1" }
        };

        var aine3 = new Aine
        {
            Nom = "Wouatcha",
            Prenom = "Paul",
            Telephone = "506-555-0103",
            Email = "paul.wouatcha@demo.local",
            PasswordHash = "temp",
            DateNaissance = new DateOnly(1955, 7, 22),
            Docteur = "Dr. Cormier",
            NumeroTelephoneDocteur = "506-555-0197",
            Adresse = new Adresse { Numero = "120", Rue = "Rue Main", Ville = "Dieppe", Province = "NB", CodePostal = "E1A1A1" }
        };

        var aine4 = new Aine
        {
            Nom = "Duguay",
            Prenom = "Ghislain",
            Telephone = "506-555-0104",
            Email = "ghislain.duguay@demo.local",
            PasswordHash = "temp",
            DateNaissance = new DateOnly(1938, 12, 1),
            Docteur = "Dr. LeBlanc",
            NumeroTelephoneDocteur = "506-555-0196",
            Adresse = new Adresse { Numero = "7", Rue = "Rue Acadie", Ville = "Shediac", Province = "NB", CodePostal = "E4P1B1" }
        };

        // ── Proches ─────────────────────────────────────────────────────────────

        var proche1 = new ProcheAidant
        {
            Nom = "Boudreau",
            Prenom = "Kayleb",
            Telephone = "506-555-0201",
            Email = "kayleb.boudreau@demo.local",
            PasswordHash = "temp",
            Adresse = new Adresse { Numero = "22", Rue = "Main St", Ville = "Dieppe", Province = "NB", CodePostal = "E1A2B2" }
        };

        var proche2 = new ProcheAidant
        {
            Nom = "Kouonang",
            Prenom = "Fabrice",
            Telephone = "506-555-0202",
            Email = "fabrice.kouonang@demo.local",
            PasswordHash = "temp",
            Adresse = new Adresse { Numero = "10", Rue = "Rue Elmwood", Ville = "Moncton", Province = "NB", CodePostal = "E1A1A1" }
        };

        var proche3 = new ProcheAidant
        {
            Nom = "Nguefack",
            Prenom = "Perez",
            Telephone = "506-555-0203",
            Email = "perez.nguefack@demo.local",
            PasswordHash = "temp",
            Adresse = new Adresse { Numero = "55", Rue = "Rue St-George", Ville = "Moncton", Province = "NB", CodePostal = "E1C1T1" }
        };

        var proche4 = new ProcheAidant
        {
            Nom = "Emmanuelle",
            Prenom = "Grace",
            Telephone = "506-555-0204",
            Email = "grace.emmanuelle@demo.local",
            PasswordHash = "temp",
            Adresse = new Adresse { Numero = "3", Rue = "Av. des Érables", Ville = "Riverview", Province = "NB", CodePostal = "E1B3C3" }
        };

        db.Users.AddRange(aine1, aine2, aine3, aine4, proche1, proche2, proche3, proche4);
        await db.SaveChangesAsync(ct);

        // Hachage des mots de passe
        foreach (var u in await db.Users.ToListAsync(ct))
        {
            if (u.PasswordHash == "temp")
                u.PasswordHash = hasher.HashPassword(u, plain);
        }
        await db.SaveChangesAsync(ct);

        // ── Dates de référence ──────────────────────────────────────────────────

        var today = DateTime.UtcNow.Date;
        var yesterday = today.AddDays(-1);
        var twoDaysAgo = today.AddDays(-2);
        var threeDaysAgo = today.AddDays(-3);

        // ── Médicaments ─────────────────────────────────────────────────────────

        var meds = new List<Medicament>
        {
            // David Roy (aine1) — médicaments cardiaques courants
            new() { Nom = "Metoprolol",    Marque = "Lopressor",  Dosage = "50 mg",    Frequence = "08:00, 20:00", AineId = aine1.Id, IsActive = true,  IsDeleted = false,
                    LastTakenAt = today.AddHours(8) },
            new() { Nom = "Ramipril",      Marque = "Altace",     Dosage = "5 mg",     Frequence = "08:00",        AineId = aine1.Id, IsActive = true,  IsDeleted = false,
                    LastTakenAt = yesterday.AddHours(8) },
            new() { Nom = "Atorvastatine", Marque = "Lipitor",    Dosage = "20 mg",    Frequence = "21:00",        AineId = aine1.Id, IsActive = true,  IsDeleted = false,
                    MissedAt = yesterday.AddHours(21) },
            new() { Nom = "Vitamine D",    Marque = "Generic",    Dosage = "1000 UI",  Frequence = "08:00",        AineId = aine1.Id, IsActive = true,  IsDeleted = false,
                    MissedAt = twoDaysAgo.AddHours(8) },
            new() { Nom = "Aspirine",      Marque = "Bayer",      Dosage = "81 mg",    Frequence = "08:00",        AineId = aine1.Id, IsActive = true,  IsDeleted = false,
                    LastTakenAt = twoDaysAgo.AddHours(8) },
            new() { Nom = "Furosémide",    Marque = "Lasix",      Dosage = "40 mg",    Frequence = "09:00",        AineId = aine1.Id, IsActive = false, IsDeleted = false,
                    MissedAt = threeDaysAgo.AddHours(9) },

            // Joel Boudreau (aine2)
            new() { Nom = "Metformine",    Marque = "Glucophage", Dosage = "500 mg",   Frequence = "07:30, 18:00", AineId = aine2.Id, IsActive = true,  IsDeleted = false,
                    LastTakenAt = today.AddHours(7).AddMinutes(30) },
            new() { Nom = "Amlodipine",    Marque = "Norvasc",    Dosage = "5 mg",     Frequence = "09:00",        AineId = aine2.Id, IsActive = true,  IsDeleted = false,
                    MissedAt = yesterday.AddHours(9) },
            new() { Nom = "Pantoprazole",  Marque = "Tecta",      Dosage = "40 mg",    Frequence = "07:00",        AineId = aine2.Id, IsActive = true,  IsDeleted = false,
                    LastTakenAt = today.AddHours(7) },

            // Paul Wouatcha (aine3)
            new() { Nom = "Levothyroxine", Marque = "Synthroid",  Dosage = "100 mcg",  Frequence = "07:00",        AineId = aine3.Id, IsActive = true,  IsDeleted = false,
                    LastTakenAt = today.AddHours(7) },
            new() { Nom = "Oméprazole",    Marque = "Losec",      Dosage = "20 mg",    Frequence = "07:30",        AineId = aine3.Id, IsActive = true,  IsDeleted = false,
                    MissedAt = twoDaysAgo.AddHours(7).AddMinutes(30) },

            // Ghislain Duguay (aine4)
            new() { Nom = "Warfarine",     Marque = "Coumadin",   Dosage = "2 mg",     Frequence = "17:00",        AineId = aine4.Id, IsActive = true,  IsDeleted = false,
                    LastTakenAt = today.AddHours(17) },
            new() { Nom = "Bisoprolol",    Marque = "Monocor",    Dosage = "5 mg",     Frequence = "08:00",        AineId = aine4.Id, IsActive = true,  IsDeleted = false,
                    MissedAt = yesterday.AddHours(8) },
            new() { Nom = "Spironolactone",Marque = "Aldactone",  Dosage = "25 mg",    Frequence = "08:00",        AineId = aine4.Id, IsActive = true,  IsDeleted = false,
                    LastTakenAt = twoDaysAgo.AddHours(8) },
        };

        db.Medicaments.AddRange(meds);
        await db.SaveChangesAsync(ct);

        // ── Rappels ─────────────────────────────────────────────────────────────

        var priseDate = DateOnly.FromDateTime(DateTime.UtcNow);

        db.Rappels.AddRange(
            new Rappel
            {
                DateDebut = priseDate,
                HeureDebut = TimeOnly.FromDateTime(DateTime.UtcNow.AddHours(1)),
                MinutesAvantRappel = 15,
                Type = "Medicament",
                Actif = true,
                MedicamentId = meds[0].Id
            },
            new Rappel
            {
                DateDebut = priseDate,
                HeureDebut = TimeOnly.FromDateTime(DateTime.UtcNow.AddHours(3)),
                MinutesAvantRappel = 10,
                Type = "Medicament",
                Actif = true,
                MedicamentId = meds[1].Id
            }
        );

        // ── Rendez-vous ─────────────────────────────────────────────────────────

        db.RendezVousMedicaux.AddRange(
            new RendezVousMedical
            {
                Docteur = "Dr. Robichaud",
                Lieu = new Adresse { Numero = "330", Rue = "Av. Université", Ville = "Moncton", Province = "NB", CodePostal = "E1C2Z6" },
                DateHeure = today.AddDays(7).AddHours(10),
                Notes = "Suivi cardiologie — apporter la liste des médicaments.",
                AineId = aine1.Id
            },
            new RendezVousMedical
            {
                Docteur = "Dr. Robichaud",
                Lieu = new Adresse { Numero = "100", Rue = "Rue St-George", Ville = "Moncton", Province = "NB", CodePostal = "E1C1T7" },
                DateHeure = today.AddDays(14).AddHours(8).AddMinutes(30),
                Notes = "Prise de sang — à jeun depuis minuit.",
                AineId = aine1.Id
            },
            new RendezVousMedical
            {
                Docteur = "Dr. Landry",
                Lieu = new Adresse { Numero = "500", Rue = "Rue Mountain", Ville = "Moncton", Province = "NB", CodePostal = "E1C8T8" },
                DateHeure = today.AddDays(3).AddHours(14),
                Notes = "Contrôle glycémie.",
                AineId = aine2.Id
            },
            new RendezVousMedical
            {
                Docteur = "Dr. LeBlanc",
                Lieu = new Adresse { Numero = "1", Rue = "Rue Providence", Ville = "Shediac", Province = "NB", CodePostal = "E4P2B2" },
                DateHeure = today.AddDays(10).AddHours(9),
                Notes = "INR — vérifier anticoagulation.",
                AineId = aine4.Id
            }
        );

        await db.SaveChangesAsync(ct);

        // ── Partages ─────────────────────────────────────────────────────────────

        db.PartagesSuivi.AddRange(
            // Kayleb suit David Roy (Écriture — fils)
            new PartageSuivi { Autorisation = "Ecriture", Relation = "Fils",  AineId = aine1.Id, ProcheAidantId = proche1.Id, Statut = "actif", CreatedAtUtc = DateTime.UtcNow },
            // Fabrice suit David Roy (Lecture — ami)
            new PartageSuivi { Autorisation = "Lecture",  Relation = "Ami",   AineId = aine1.Id, ProcheAidantId = proche2.Id, Statut = "actif", CreatedAtUtc = DateTime.UtcNow },
            // Kayleb suit Joel Boudreau (Écriture — fils)
            new PartageSuivi { Autorisation = "Ecriture", Relation = "Fils",  AineId = aine2.Id, ProcheAidantId = proche1.Id, Statut = "actif", CreatedAtUtc = DateTime.UtcNow },
            // Perez suit Paul Wouatcha (Lecture — neveu)
            new PartageSuivi { Autorisation = "Lecture",  Relation = "Neveu", AineId = aine3.Id, ProcheAidantId = proche3.Id, Statut = "actif", CreatedAtUtc = DateTime.UtcNow },
            // Grace suit Ghislain Duguay (Écriture — fille)
            new PartageSuivi { Autorisation = "Ecriture", Relation = "Fille", AineId = aine4.Id, ProcheAidantId = proche4.Id, Statut = "actif", CreatedAtUtc = DateTime.UtcNow },
            // Fabrice suit Ghislain Duguay (Lecture — ami)
            new PartageSuivi { Autorisation = "Lecture",  Relation = "Ami",   AineId = aine4.Id, ProcheAidantId = proche2.Id, Statut = "actif", CreatedAtUtc = DateTime.UtcNow }
        );

        await db.SaveChangesAsync(ct);
    }
}
