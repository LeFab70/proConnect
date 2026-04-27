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

        var seedEnabled = string.Equals(Environment.GetEnvironmentVariable("SEED_DATA"), "true", StringComparison.OrdinalIgnoreCase);
        if (!seedEnabled) return;

        if (!await db.Users.AnyAsync(ct))
        {
            db.Users.AddRange(
                new StandardUser { Nom = "Kouonang", Prenom = "Fabrice", Telephone = "506-000-0001", Email = "fabrice@proconnect.local", PasswordHash = "temp" },
                new StandardUser { Nom = "Aubie", Prenom = "Kayleb", Telephone = "506-000-0002", Email = "kayleb@proconnect.local", PasswordHash = "temp" },
                new StandardUser { Nom = "Perez", Prenom = "Perez", Telephone = "506-000-0003", Email = "perez@proconnect.local", PasswordHash = "temp" },
                new StandardUser { Nom = "Grace", Prenom = "Grace", Telephone = "506-000-0004", Email = "grace@proconnect.local", PasswordHash = "temp" }
            );
        }

        if (!await db.Aines.AnyAsync(ct))
        {
            db.Aines.Add(new Aine
            {
                Nom = "Dupont",
                Prenom = "Marie",
                Telephone = "333-333-3333",
                Email = "marie.dupont@proconnect.local",
                PasswordHash = "temp",
                DateNaissance = new DateOnly(1948, 5, 12),
                Adresse = new Adresse
                {
                    Numero = "123",
                    Rue = "Rue Principale",
                    Ville = "Moncton",
                    Province = "NB",
                    CodePostal = "E1A 1A1"
                },
                Docteur = "Dr. Mimiche",
                NumeroTelephoneDocteur = "506-783-4567"
            });
        }

        if (!await db.ProchesAidants.AnyAsync(ct))
        {
            db.ProchesAidants.Add(new ProcheAidant
            {
                Nom = "Martin",
                Prenom = "Alex",
                Telephone = "444-444-4444",
                Email = "alex.martin@proconnect.local",
                PasswordHash = "temp"
            });
        }

        await db.SaveChangesAsync(ct);

        var plain = Environment.GetEnvironmentVariable("SEED_PASSWORD") ?? "Password123!";
        var toUpdate = await db.Users.ToListAsync(ct);
        foreach (var u in toUpdate)
        {
            if (u.PasswordHash == "temp")
            {
                u.PasswordHash = hasher.HashPassword(u, plain);
            }
        }
        await db.SaveChangesAsync(ct);

        var aine = await db.Aines.AsNoTracking().FirstOrDefaultAsync(ct);
        if (aine != null && !await db.Medicaments.AnyAsync(ct))
        {
            db.Medicaments.Add(new Medicament
            {
                Nom = "Vitamine D",
                Marque = "D-Vit",
                Dosage = "1000 MG",
                Frequence = "1x/jour",
                AineId = aine.Id,
                IsActive = true,
                IsDeleted = false
            });
        }

        if (aine != null && !await db.RendezVousMedicaux.AnyAsync(ct))
        {
            db.RendezVousMedicaux.Add(new RendezVousMedical
            {
                DateHeure = DateTime.UtcNow.AddDays(14),
                Lieu = new Adresse
                {
                    Numero = "456",
                    Rue = "Avenue du Centre",
                    Ville = "Moncton",
                    Province = "NB",
                    CodePostal = "E1A 1A2"
                },
                Docteur = "Cardiologue",
                Notes = "Suivi annuel",
                AineId = aine.Id
            });
        }

        await db.SaveChangesAsync(ct);

        if (!await db.Rappels.AnyAsync(ct))
        {
            var med = await db.Medicaments.AsNoTracking().FirstOrDefaultAsync(ct);
            if (med != null)
            {
                var when = DateTime.UtcNow.AddHours(6);
                db.Rappels.Add(new Rappel
                {
                    DateDebut = DateOnly.FromDateTime(when),
                    HeureDebut = TimeOnly.FromDateTime(when),
                    MinutesAvantRappel = 15,
                    Type = "Medicament",
                    Actif = true,
                    MedicamentId = med.Id
                });
            }
        }

        await db.SaveChangesAsync(ct);
    }
}