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
        var seedEnabled = string.IsNullOrWhiteSpace(seedVar) ||
                          string.Equals(seedVar, "true", StringComparison.OrdinalIgnoreCase) ||
                          seedVar == "1" ||
                          string.Equals(seedVar, "yes", StringComparison.OrdinalIgnoreCase);
        if (!seedEnabled) return;

        // Seed cleaned: reset and recreate ONLY the minimal dataset used by the app.
        // - 7 aînés (see list below), with max 3 médicaments each
        // - only the dev accounts as ProcheAidant (kayleb, fabrice, perez, grace)
        // - PartageSuivi links: each dev follows 2-3 aînés
        //
        // WARNING: this deletes all existing rows in core tables.
        await db.Database.ExecuteSqlRawAsync("""
            DELETE FROM rappels;
            DELETE FROM partages_suivi;
            DELETE FROM medicaments;
            DELETE FROM rendez_vous_medicaux;
            DELETE FROM users;
            """, ct);

        static string Unsplash(string keyword, int sig) =>
            $"https://source.unsplash.com/featured/600x600?{Uri.EscapeDataString(keyword)}&sig={sig}";

        var toAddUsers = new List<User>();

        // Dev comptes (ProcheAidant)
        toAddUsers.Add(new ProcheAidant { Nom = "Kouonang", Prenom = "Fabrice", Telephone = "506-000-0001", Email = "fabrice@proconnect.local", PasswordHash = "temp", Adresse = new Adresse { Numero = "10", Rue = "Rue Elmwood", Ville = "Moncton", Province = "NB", CodePostal = "E1A1A1" } });
        toAddUsers.Add(new ProcheAidant { Nom = "Aubie", Prenom = "Kayleb", Telephone = "506-000-0002", Email = "kayleb@proconnect.local", PasswordHash = "temp", Adresse = new Adresse { Numero = "22", Rue = "Main St", Ville = "Dieppe", Province = "NB", CodePostal = "E1A2B2" } });
        toAddUsers.Add(new ProcheAidant { Nom = "Perez", Prenom = "Perez", Telephone = "506-000-0003", Email = "perez@proconnect.local", PasswordHash = "temp", Adresse = new Adresse { Numero = "5", Rue = "Rue Church", Ville = "Moncton", Province = "NB", CodePostal = "E1A3C3" } });
        toAddUsers.Add(new ProcheAidant { Nom = "Grace", Prenom = "Grace", Telephone = "506-000-0004", Email = "grace@proconnect.local", PasswordHash = "temp", Adresse = new Adresse { Numero = "18", Rue = "King St", Ville = "Riverview", Province = "NB", CodePostal = "E1B1B1" } });

        // Aînés de test demandés
        toAddUsers.Add(new Aine { Nom = "Boudreau", Prenom = "Jeol", Telephone = "333-333-1001", Email = "joel.boudreau@proconnect.local", PasswordHash = "temp", DateNaissance = new DateOnly(1948, 5, 12), Adresse = new Adresse { Numero = "123", Rue = "Rue Principale", Ville = "Moncton", Province = "NB", CodePostal = "E1A1A1" }, Docteur = "Dr. Mimiche", NumeroTelephoneDocteur = "506-783-4567" });
        toAddUsers.Add(new Aine { Nom = "Roy", Prenom = "David", Telephone = "333-333-1002", Email = "david.roy@proconnect.local", PasswordHash = "temp", DateNaissance = new DateOnly(1942, 10, 3), Adresse = new Adresse { Numero = "9", Rue = "Rue du Parc", Ville = "Riverview", Province = "NB", CodePostal = "E1B2C2" }, Docteur = "Dr. Nguyen", NumeroTelephoneDocteur = "506-111-2222" });
        toAddUsers.Add(new Aine { Nom = "Wouatcha", Prenom = "Paul", Telephone = "333-333-1003", Email = "paul.wouatcha@proconnect.local", PasswordHash = "temp", DateNaissance = new DateOnly(1950, 2, 19), Adresse = new Adresse { Numero = "44", Rue = "Rue Victoria", Ville = "Dieppe", Province = "NB", CodePostal = "E1A9Z9" }, Docteur = "Dr. Patel", NumeroTelephoneDocteur = "506-222-3333" });
        toAddUsers.Add(new Aine { Nom = "Trembley", Prenom = "Michel", Telephone = "333-333-1004", Email = "michel.trembley@proconnect.local", PasswordHash = "temp", DateNaissance = new DateOnly(1939, 7, 7), Adresse = new Adresse { Numero = "61", Rue = "Rue Champlain", Ville = "Moncton", Province = "NB", CodePostal = "E1C1C1" }, Docteur = "Dr. Singh", NumeroTelephoneDocteur = "506-333-4444" });
        toAddUsers.Add(new Aine { Nom = "Ndiaye", Prenom = "Ghislain", Telephone = "333-333-1005", Email = "ghislain.ndiaye@proconnect.local", PasswordHash = "temp", DateNaissance = new DateOnly(1946, 1, 22), Adresse = new Adresse { Numero = "14", Rue = "Rue St-George", Ville = "Moncton", Province = "NB", CodePostal = "E1C2C2" }, Docteur = "Dr. Brown", NumeroTelephoneDocteur = "506-555-6666" });
        toAddUsers.Add(new Aine { Nom = "Robichaud", Prenom = "Michel", Telephone = "333-333-1006", Email = "michel.robichaud@proconnect.local", PasswordHash = "temp", DateNaissance = new DateOnly(1940, 9, 5), Adresse = new Adresse { Numero = "200", Rue = "Rue Mountain", Ville = "Moncton", Province = "NB", CodePostal = "E1C3C3" }, Docteur = "Dr. White", NumeroTelephoneDocteur = "506-777-8888" });
        toAddUsers.Add(new Aine { Nom = "Kamla", Prenom = "Brice", Telephone = "333-333-1007", Email = "brice.kamla@proconnect.local", PasswordHash = "temp", DateNaissance = new DateOnly(1944, 3, 15), Adresse = new Adresse { Numero = "88", Rue = "Rue Acadie", Ville = "Dieppe", Province = "NB", CodePostal = "E1A5E5" }, Docteur = "Dr. Martin", NumeroTelephoneDocteur = "506-999-0000" });

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

        var aines = await db.Aines.AsNoTracking().OrderBy(x => x.Id).ToListAsync(ct);
        if (aines.Count > 0)
        {
            var sig = 1;
            foreach (var aine in aines)
            {
                var meds = new List<Medicament>
                {
                    new() { Nom = "Vitamine D", Marque = "D-Vit", Dosage = "1000 MG", Frequence = "1x/jour", UrlPhoto = Unsplash("vitamin pills", sig++), AineId = aine.Id, IsActive = true, IsDeleted = false },
                    new() { Nom = "Aspirine", Marque = "Bayer", Dosage = "81 MG", Frequence = "1x/jour", UrlPhoto = Unsplash("medicine bottle", sig++), AineId = aine.Id, IsActive = true, IsDeleted = false },
                    new() { Nom = "Metformine", Marque = "Generic", Dosage = "500 MG", Frequence = "2x/jour", UrlPhoto = Unsplash("pharmacy pills", sig++), AineId = aine.Id, IsActive = true, IsDeleted = false },
                };

                db.Medicaments.AddRange(meds.Take(3));
            }
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

        // PartageSuivi: link dev comptes to 2-3 aînés
        var paFabrice = await db.ProchesAidants.AsNoTracking()
            .FirstAsync(p => p.Email == "fabrice@proconnect.local", ct);
        var paKayleb = await db.ProchesAidants.AsNoTracking()
            .FirstAsync(p => p.Email == "kayleb@proconnect.local", ct);
        var paPerez = await db.ProchesAidants.AsNoTracking()
            .FirstAsync(p => p.Email == "perez@proconnect.local", ct);
        var paGrace = await db.ProchesAidants.AsNoTracking()
            .FirstAsync(p => p.Email == "grace@proconnect.local", ct);

        // Ensure stable ordering of aînés
        var a = aines;
        if (a.Count >= 7)
        {
            PartageSuivi Link(string autorisation, string relation, long aineId, long procheAidantId) => new()
            {
                Autorisation = autorisation,
                Relation = relation,
                AineId = aineId,
                ProcheAidantId = procheAidantId,
                Statut = "actif",
                CreatedAtUtc = DateTime.UtcNow
            };

            db.PartagesSuivi.AddRange(
                Link("Ecriture", "Dev", a[0].Id, paFabrice.Id),
                Link("Lecture", "Dev", a[1].Id, paFabrice.Id),
                Link("Lecture", "Dev", a[2].Id, paFabrice.Id),

                Link("Lecture", "Dev", a[2].Id, paKayleb.Id),
                Link("Ecriture", "Dev", a[3].Id, paKayleb.Id),
                Link("Lecture", "Dev", a[4].Id, paKayleb.Id),

                Link("Lecture", "Dev", a[4].Id, paPerez.Id),
                Link("Lecture", "Dev", a[5].Id, paPerez.Id),

                Link("Ecriture", "Dev", a[6].Id, paGrace.Id),
                Link("Lecture", "Dev", a[0].Id, paGrace.Id)
            );
        }

        await db.SaveChangesAsync(ct);
    }
}