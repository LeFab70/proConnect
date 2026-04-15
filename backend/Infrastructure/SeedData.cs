using backend.Models;
using Microsoft.EntityFrameworkCore;

namespace backend.Infrastructure;

public static class SeedData
{
    public static async Task ApplyMigrationsAndSeedAsync(IServiceProvider services, CancellationToken ct = default)
    {
        using var scope = services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();

        await db.Database.MigrateAsync(ct);

        var seedEnabled = string.Equals(Environment.GetEnvironmentVariable("SEED_DATA"), "true", StringComparison.OrdinalIgnoreCase);
        if (!seedEnabled) return;

        if (!await db.Users.AnyAsync(ct))
        {
            db.Users.AddRange(
                new StandardUser { KeycloakId = "seed-fabrice-sub", Nom = "Kouonang", Prenom = "Fabrice", Telephone = "506-000-0001", Email = "fabrice@proconnect.local" },
                new StandardUser { KeycloakId = "seed-kayleb-sub", Nom = "Aubie", Prenom = "Kayleb", Telephone = "506-000-0002", Email = "kayleb@proconnect.local" },
                new StandardUser { KeycloakId = "seed-perez-sub", Nom = "Perez", Prenom = "Perez", Telephone = "506-000-0003", Email = "perez@proconnect.local" },
                new StandardUser { KeycloakId = "seed-grace-sub", Nom = "Grace", Prenom = "Grace", Telephone = "506-000-0004", Email = "grace@proconnect.local" }
            );
        }

        if (!await db.Aines.AnyAsync(ct))
        {
            db.Aines.Add(new Aine
            {
                KeycloakId = "seed-aine-sub",
                Nom = "Dupont",
                Prenom = "Marie",
                Telephone = "333-333-3333",
                Email = "marie.dupont@proconnect.local",
                DateNaissance = new DateOnly(1948, 5, 12),
                Adresse = "123 Rue Principale, Moncton, NB"
            });
        }

        if (!await db.ProchesAidants.AnyAsync(ct))
        {
            db.ProchesAidants.Add(new ProcheAidant
            {
                KeycloakId = "seed-proche-sub",
                Nom = "Martin",
                Prenom = "Alex",
                Telephone = "444-444-4444",
                Email = "alex.martin@proconnect.local",
                Relation = "Fils"
            });
        }

        await db.SaveChangesAsync(ct);

        // Seed dépendant des IDs (après SaveChanges)
        var aine = await db.Aines.AsNoTracking().FirstOrDefaultAsync(ct);
        if (aine != null && !await db.Medicaments.AnyAsync(ct))
        {
            db.Medicaments.Add(new Medicament
            {
                Nom = "Vitamine D",
                Dosage = "1000 UI",
                Frequence = "1x/jour",
                AineId = aine.Id
            });
        }

        if (aine != null && !await db.RendezVousMedicaux.AnyAsync(ct))
        {
            db.RendezVousMedicaux.Add(new RendezVousMedical
            {
                DateHeure = DateTime.UtcNow.AddDays(14),
                Lieu = "Clinique NB",
                Specialiste = "Cardiologue",
                Notes = "Suivi annuel",
                AineId = aine.Id
            });
        }

        await db.SaveChangesAsync(ct);

        if (!await db.Rappels.AnyAsync(ct))
        {
            var med = await db.Medicaments.AsNoTracking().FirstOrDefaultAsync(ct);
            db.Rappels.Add(new Rappel
            {
                DateHeure = DateTime.UtcNow.AddHours(6),
                Type = "Medicament",
                Actif = true,
                MedicamentId = med?.Id
            });
        }

        await db.SaveChangesAsync(ct);
    }
}

