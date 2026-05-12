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

        // ── Utilisateurs ────────────────────────────────────────────────────────

        var aine = new Aine
        {
            Nom = "Roy",
            Prenom = "David",
            Telephone = "506-555-0100",
            Email = "david.roy@demo.local",
            PasswordHash = "temp",
            DateNaissance = new DateOnly(1942, 10, 3),
            Docteur = "Dr. Robichaud",
            NumeroTelephoneDocteur = "506-555-0199",
            Adresse = new Adresse
            {
                Numero = "9",
                Rue = "Rue du Parc",
                Ville = "Riverview",
                Province = "NB",
                CodePostal = "E1B2C2"
            }
        };

        var proche1 = new ProcheAidant
        {
            Nom = "Kouonang",
            Prenom = "Fabrice",
            Telephone = "506-555-0201",
            Email = "fabrice.kouonang@demo.local",
            PasswordHash = "temp",
            Adresse = new Adresse
            {
                Numero = "10",
                Rue = "Rue Elmwood",
                Ville = "Moncton",
                Province = "NB",
                CodePostal = "E1A1A1"
            }
        };

        var proche2 = new ProcheAidant
        {
            Nom = "Boudreau",
            Prenom = "Kayleb",
            Telephone = "506-555-0202",
            Email = "kayleb.boudreau@demo.local",
            PasswordHash = "temp",
            Adresse = new Adresse
            {
                Numero = "22",
                Rue = "Main St",
                Ville = "Dieppe",
                Province = "NB",
                CodePostal = "E1A2B2"
            }
        };

        db.Users.AddRange(aine, proche1, proche2);
        await db.SaveChangesAsync(ct);

        // Hachage des mots de passe
        foreach (var u in await db.Users.ToListAsync(ct))
        {
            if (u.PasswordHash == "temp")
                u.PasswordHash = hasher.HashPassword(u, plain);
        }
        await db.SaveChangesAsync(ct);

        // ── Médicaments ─────────────────────────────────────────────────────────

        var today = DateTime.UtcNow.Date;

        var meds = new List<Medicament>
        {
            new() { Nom = "Metoprolol",   Marque = "Lopressor",  Dosage = "50 MG",   Frequence = "2x/jour",  AineId = aine.Id, IsActive = true, IsDeleted = false },
            new() { Nom = "Ramipril",     Marque = "Altace",     Dosage = "5 MG",    Frequence = "1x/jour",  AineId = aine.Id, IsActive = true, IsDeleted = false },
            new() { Nom = "Atorvastatine",Marque = "Lipitor",    Dosage = "20 MG",   Frequence = "1x/soir",  AineId = aine.Id, IsActive = true, IsDeleted = false },
            new() { Nom = "Vitamine D",   Marque = "Generic",    Dosage = "1000 UI", Frequence = "1x/jour",  AineId = aine.Id, IsActive = true, IsDeleted = false },
        };

        db.Medicaments.AddRange(meds);
        await db.SaveChangesAsync(ct);

        // ── Rappels ─────────────────────────────────────────────────────────────

        var priseHeure = TimeOnly.FromDateTime(DateTime.UtcNow.AddHours(1));
        var priseDate  = DateOnly.FromDateTime(DateTime.UtcNow);

        db.Rappels.AddRange(
            new Rappel
            {
                DateDebut = priseDate,
                HeureDebut = priseHeure,
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
                DateHeure = DateTime.UtcNow.Date.AddDays(7).AddHours(10),
                Notes = "Suivi cardiologie — apporter la liste des médicaments.",
                AineId = aine.Id
            },
            new RendezVousMedical
            {
                Docteur = "Dr. Robichaud",
                Lieu = new Adresse { Numero = "100", Rue = "Rue St-George", Ville = "Moncton", Province = "NB", CodePostal = "E1C1T7" },
                DateHeure = DateTime.UtcNow.Date.AddDays(14).AddHours(8).AddMinutes(30),
                Notes = "Prise de sang — à jeun depuis minuit.",
                AineId = aine.Id
            }
        );

        await db.SaveChangesAsync(ct);

        // ── Partages ─────────────────────────────────────────────────────────────

        db.PartagesSuivi.AddRange(
            new PartageSuivi
            {
                Autorisation = "Ecriture",
                Relation = "Fille",
                AineId = aine.Id,
                ProcheAidantId = proche1.Id,
                Statut = "actif",
                CreatedAtUtc = DateTime.UtcNow
            },
            new PartageSuivi
            {
                Autorisation = "Lecture",
                Relation = "Ami",
                AineId = aine.Id,
                ProcheAidantId = proche2.Id,
                Statut = "actif",
                CreatedAtUtc = DateTime.UtcNow
            }
        );

        await db.SaveChangesAsync(ct);
    }
}
