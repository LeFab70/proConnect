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

        static string Unsplash(string keyword, int sig) =>
            $"https://source.unsplash.com/featured/600x600?{Uri.EscapeDataString(keyword)}&sig={sig}";

        // Users (StandardUser / Aine / ProcheAidant) — insert if missing by email
        var usersByEmail = await db.Users.AsNoTracking().Select(u => u.Email.ToLower()).ToListAsync(ct);
        bool Has(string email) => usersByEmail.Contains(email.ToLower());

        var toAddUsers = new List<User>();

        if (!Has("fabrice@proconnect.local"))
            toAddUsers.Add(new StandardUser { Nom = "Kouonang", Prenom = "Fabrice", Telephone = "506-000-0001", Email = "fabrice@proconnect.local", PasswordHash = "temp", Adresse = new Adresse { Numero = "10", Rue = "Rue Elmwood", Ville = "Moncton", Province = "NB", CodePostal = "E1A1A1" } });
        if (!Has("kayleb@proconnect.local"))
            toAddUsers.Add(new StandardUser { Nom = "Aubie", Prenom = "Kayleb", Telephone = "506-000-0002", Email = "kayleb@proconnect.local", PasswordHash = "temp", Adresse = new Adresse { Numero = "22", Rue = "Main St", Ville = "Dieppe", Province = "NB", CodePostal = "E1A2B2" } });
        if (!Has("perez@proconnect.local"))
            toAddUsers.Add(new StandardUser { Nom = "Perez", Prenom = "Perez", Telephone = "506-000-0003", Email = "perez@proconnect.local", PasswordHash = "temp", Adresse = new Adresse { Numero = "5", Rue = "Rue Church", Ville = "Moncton", Province = "NB", CodePostal = "E1A3C3" } });
        if (!Has("grace@proconnect.local"))
            toAddUsers.Add(new StandardUser { Nom = "Grace", Prenom = "Grace", Telephone = "506-000-0004", Email = "grace@proconnect.local", PasswordHash = "temp", Adresse = new Adresse { Numero = "18", Rue = "King St", Ville = "Riverview", Province = "NB", CodePostal = "E1B1B1" } });

        if (!Has("alex.martin@proconnect.local"))
            toAddUsers.Add(new ProcheAidant { Nom = "Martin", Prenom = "Alex", Telephone = "444-444-4444", Email = "alex.martin@proconnect.local", PasswordHash = "temp", Adresse = new Adresse { Numero = "77", Rue = "Avenue Maple", Ville = "Moncton", Province = "NB", CodePostal = "E1A4D4" } });
        if (!Has("sarah.leblanc@proconnect.local"))
            toAddUsers.Add(new ProcheAidant { Nom = "Leblanc", Prenom = "Sarah", Telephone = "444-444-5555", Email = "sarah.leblanc@proconnect.local", PasswordHash = "temp", Adresse = new Adresse { Numero = "3", Rue = "Rue Acadie", Ville = "Dieppe", Province = "NB", CodePostal = "E1A5E5" } });

        if (!Has("marie.dupont@proconnect.local"))
            toAddUsers.Add(new Aine { Nom = "Dupont", Prenom = "Marie", Telephone = "333-333-3333", Email = "marie.dupont@proconnect.local", PasswordHash = "temp", DateNaissance = new DateOnly(1948, 5, 12), Adresse = new Adresse { Numero = "123", Rue = "Rue Principale", Ville = "Moncton", Province = "NB", CodePostal = "E1A1A1" }, Docteur = "Dr. Mimiche", NumeroTelephoneDocteur = "506-783-4567" });
        if (!Has("jean.tremblay@proconnect.local"))
            toAddUsers.Add(new Aine { Nom = "Tremblay", Prenom = "Jean", Telephone = "333-333-1111", Email = "jean.tremblay@proconnect.local", PasswordHash = "temp", DateNaissance = new DateOnly(1942, 10, 3), Adresse = new Adresse { Numero = "9", Rue = "Rue du Parc", Ville = "Riverview", Province = "NB", CodePostal = "E1B2C2" }, Docteur = "Dr. Nguyen", NumeroTelephoneDocteur = "506-111-2222" });
        if (!Has("fatima.benali@proconnect.local"))
            toAddUsers.Add(new Aine { Nom = "Benali", Prenom = "Fatima", Telephone = "333-333-2222", Email = "fatima.benali@proconnect.local", PasswordHash = "temp", DateNaissance = new DateOnly(1950, 2, 19), Adresse = new Adresse { Numero = "44", Rue = "Rue Victoria", Ville = "Dieppe", Province = "NB", CodePostal = "E1A9Z9" }, Docteur = "Dr. Patel", NumeroTelephoneDocteur = "506-222-3333" });
        if (!Has("luc.roy@proconnect.local"))
            toAddUsers.Add(new Aine { Nom = "Roy", Prenom = "Luc", Telephone = "333-333-4444", Email = "luc.roy@proconnect.local", PasswordHash = "temp", DateNaissance = new DateOnly(1939, 7, 7), Adresse = new Adresse { Numero = "61", Rue = "Rue Champlain", Ville = "Moncton", Province = "NB", CodePostal = "E1C1C1" }, Docteur = "Dr. Singh", NumeroTelephoneDocteur = "506-333-4444" });

        if (toAddUsers.Count > 0) db.Users.AddRange(toAddUsers);

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

        var aines = await db.Aines.AsNoTracking().OrderBy(a => a.Id).ToListAsync(ct);
        if (aines.Count > 0 && !await db.Medicaments.AnyAsync(ct))
        {
            var sig = 1;
            foreach (var a in aines.Take(3))
            {
                db.Medicaments.AddRange(
                    new Medicament { Nom = "Vitamine D", Marque = "D-Vit", Dosage = "1000 MG", Frequence = "1x/jour", UrlPhoto = Unsplash("vitamin pills", sig++), AineId = a.Id, IsActive = true, IsDeleted = false },
                    new Medicament { Nom = "Aspirine", Marque = "Bayer", Dosage = "81 MG", Frequence = "1x/jour", UrlPhoto = Unsplash("medicine bottle", sig++), AineId = a.Id, IsActive = true, IsDeleted = false },
                    new Medicament { Nom = "Metformine", Marque = "Generic", Dosage = "500 MG", Frequence = "2x/jour", UrlPhoto = Unsplash("pharmacy pills", sig++), AineId = a.Id, IsActive = true, IsDeleted = false }
                );
            }
        }

        if (aines.Count > 0 && !await db.RendezVousMedicaux.AnyAsync(ct))
        {
            db.RendezVousMedicaux.AddRange(
                new RendezVousMedical
                {
                    DateHeure = DateTime.UtcNow.AddDays(14),
                    Lieu = new Adresse { Numero = "456", Rue = "Avenue du Centre", Ville = "Moncton", Province = "NB", CodePostal = "E1A 1A2" },
                    Docteur = "Cardiologue",
                    Notes = "Suivi annuel",
                    AineId = aines[0].Id
                },
                new RendezVousMedical
                {
                    DateHeure = DateTime.UtcNow.AddDays(3),
                    Lieu = new Adresse { Numero = "12", Rue = "Rue de l'Hôpital", Ville = "Dieppe", Province = "NB", CodePostal = "E1A 7Z7" },
                    Docteur = "Généraliste",
                    Notes = "Renouvellement ordonnance",
                    AineId = aines.Count > 1 ? aines[1].Id : aines[0].Id
                }
            );
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

        if (!await db.PartagesSuivi.AnyAsync(ct))
        {
            var paAlex = await db.ProchesAidants.AsNoTracking().FirstOrDefaultAsync(p => p.Email == "alex.martin@proconnect.local", ct);
            var paSarah = await db.ProchesAidants.AsNoTracking().FirstOrDefaultAsync(p => p.Email == "sarah.leblanc@proconnect.local", ct);

            if (aines.Count > 0 && paAlex != null)
            {
                db.PartagesSuivi.AddRange(
                    new PartageSuivi { Autorisation = "Lecture", Relation = "Fils", AineId = aines[0].Id, ProcheAidantId = paAlex.Id },
                    new PartageSuivi { Autorisation = "Ecriture", Relation = "Fils", AineId = aines.Count > 1 ? aines[1].Id : aines[0].Id, ProcheAidantId = paAlex.Id }
                );
            }

            if (aines.Count > 2 && paSarah != null)
            {
                db.PartagesSuivi.Add(new PartageSuivi { Autorisation = "Lecture", Relation = "Voisine", AineId = aines[2].Id, ProcheAidantId = paSarah.Id });
            }
        }

        await db.SaveChangesAsync(ct);
    }
}