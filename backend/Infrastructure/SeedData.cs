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

        // Remplacement "Option 2" : on supprime les anciens aînés seedés (et leurs dépendances)
        // pour éviter de cumuler plusieurs jeux de données de test.
        var oldAineEmails = new[]
        {
            "marie.dupont@proconnect.local",
            "jean.tremblay@proconnect.local",
            "fatima.benali@proconnect.local",
            "luc.roy@proconnect.local",
            "madeleine.gagnon@proconnect.local",
            "andre.lemieux@proconnect.local"
        };

        await db.Database.ExecuteSqlInterpolatedAsync($"""
            DELETE FROM rappels
            WHERE medicament_id IN (
                SELECT m."Id" FROM medicaments m
                WHERE m.aine_id IN (SELECT u."Id" FROM users u WHERE lower(u.email) = ANY ({oldAineEmails.Select(x => x.ToLower()).ToArray()}))
            )
            OR rendez_vous_medical_id IN (
                SELECT r."Id" FROM rendez_vous_medicaux r
                WHERE r.aine_id IN (SELECT u."Id" FROM users u WHERE lower(u.email) = ANY ({oldAineEmails.Select(x => x.ToLower()).ToArray()}))
            );
            """, ct);

        await db.Database.ExecuteSqlInterpolatedAsync($"""
            DELETE FROM partages_suivi
            WHERE aine_id IN (SELECT u."Id" FROM users u WHERE lower(u.email) = ANY ({oldAineEmails.Select(x => x.ToLower()).ToArray()}));
            """, ct);

        await db.Database.ExecuteSqlInterpolatedAsync($"""
            DELETE FROM medicaments
            WHERE aine_id IN (SELECT u."Id" FROM users u WHERE lower(u.email) = ANY ({oldAineEmails.Select(x => x.ToLower()).ToArray()}));
            """, ct);

        await db.Database.ExecuteSqlInterpolatedAsync($"""
            DELETE FROM rendez_vous_medicaux
            WHERE aine_id IN (SELECT u."Id" FROM users u WHERE lower(u.email) = ANY ({oldAineEmails.Select(x => x.ToLower()).ToArray()}));
            """, ct);

        await db.Database.ExecuteSqlInterpolatedAsync($"""
            DELETE FROM users
            WHERE lower(email) = ANY ({oldAineEmails.Select(x => x.ToLower()).ToArray()}) AND type = 'Aine';
            """, ct);

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

        // Proches aidants de test avec les noms du groupe (emails distincts)
        if (!Has("fabrice.aidant@proconnect.local"))
            toAddUsers.Add(new ProcheAidant { Nom = "Kouonang", Prenom = "Fabrice", Telephone = "506-111-0001", Email = "fabrice.aidant@proconnect.local", PasswordHash = "temp", Adresse = new Adresse { Numero = "10", Rue = "Rue Elmwood", Ville = "Moncton", Province = "NB", CodePostal = "E1A1A1" } });
        if (!Has("kayleb.aidant@proconnect.local"))
            toAddUsers.Add(new ProcheAidant { Nom = "Aubie", Prenom = "Kayleb", Telephone = "506-111-0002", Email = "kayleb.aidant@proconnect.local", PasswordHash = "temp", Adresse = new Adresse { Numero = "22", Rue = "Main St", Ville = "Dieppe", Province = "NB", CodePostal = "E1A2B2" } });
        if (!Has("perez.aidant@proconnect.local"))
            toAddUsers.Add(new ProcheAidant { Nom = "Perez", Prenom = "Perez", Telephone = "506-111-0003", Email = "perez.aidant@proconnect.local", PasswordHash = "temp", Adresse = new Adresse { Numero = "5", Rue = "Rue Church", Ville = "Moncton", Province = "NB", CodePostal = "E1A3C3" } });
        if (!Has("grace.aidant@proconnect.local"))
            toAddUsers.Add(new ProcheAidant { Nom = "Grace", Prenom = "Grace", Telephone = "506-111-0004", Email = "grace.aidant@proconnect.local", PasswordHash = "temp", Adresse = new Adresse { Numero = "18", Rue = "King St", Ville = "Riverview", Province = "NB", CodePostal = "E1B1B1" } });

        if (!Has("alex.martin@proconnect.local"))
            toAddUsers.Add(new ProcheAidant { Nom = "Martin", Prenom = "Alex", Telephone = "444-444-4444", Email = "alex.martin@proconnect.local", PasswordHash = "temp", Adresse = new Adresse { Numero = "77", Rue = "Avenue Maple", Ville = "Moncton", Province = "NB", CodePostal = "E1A4D4" } });
        if (!Has("sarah.leblanc@proconnect.local"))
            toAddUsers.Add(new ProcheAidant { Nom = "Leblanc", Prenom = "Sarah", Telephone = "444-444-5555", Email = "sarah.leblanc@proconnect.local", PasswordHash = "temp", Adresse = new Adresse { Numero = "3", Rue = "Rue Acadie", Ville = "Dieppe", Province = "NB", CodePostal = "E1A5E5" } });

        // Aînés de test demandés
        if (!Has("joel.boudreau@proconnect.local"))
            toAddUsers.Add(new Aine { Nom = "Boudreau", Prenom = "Jeol", Telephone = "333-333-1001", Email = "joel.boudreau@proconnect.local", PasswordHash = "temp", DateNaissance = new DateOnly(1948, 5, 12), Adresse = new Adresse { Numero = "123", Rue = "Rue Principale", Ville = "Moncton", Province = "NB", CodePostal = "E1A1A1" }, Docteur = "Dr. Mimiche", NumeroTelephoneDocteur = "506-783-4567" });
        if (!Has("david.roy@proconnect.local"))
            toAddUsers.Add(new Aine { Nom = "Roy", Prenom = "David", Telephone = "333-333-1002", Email = "david.roy@proconnect.local", PasswordHash = "temp", DateNaissance = new DateOnly(1942, 10, 3), Adresse = new Adresse { Numero = "9", Rue = "Rue du Parc", Ville = "Riverview", Province = "NB", CodePostal = "E1B2C2" }, Docteur = "Dr. Nguyen", NumeroTelephoneDocteur = "506-111-2222" });
        if (!Has("paul.wouatcha@proconnect.local"))
            toAddUsers.Add(new Aine { Nom = "Wouatcha", Prenom = "Paul", Telephone = "333-333-1003", Email = "paul.wouatcha@proconnect.local", PasswordHash = "temp", DateNaissance = new DateOnly(1950, 2, 19), Adresse = new Adresse { Numero = "44", Rue = "Rue Victoria", Ville = "Dieppe", Province = "NB", CodePostal = "E1A9Z9" }, Docteur = "Dr. Patel", NumeroTelephoneDocteur = "506-222-3333" });
        if (!Has("michel.trembley@proconnect.local"))
            toAddUsers.Add(new Aine { Nom = "Trembley", Prenom = "Michel", Telephone = "333-333-1004", Email = "michel.trembley@proconnect.local", PasswordHash = "temp", DateNaissance = new DateOnly(1939, 7, 7), Adresse = new Adresse { Numero = "61", Rue = "Rue Champlain", Ville = "Moncton", Province = "NB", CodePostal = "E1C1C1" }, Docteur = "Dr. Singh", NumeroTelephoneDocteur = "506-333-4444" });
        if (!Has("ghislain.ndiaye@proconnect.local"))
            toAddUsers.Add(new Aine { Nom = "Ndiaye", Prenom = "Ghislain", Telephone = "333-333-1005", Email = "ghislain.ndiaye@proconnect.local", PasswordHash = "temp", DateNaissance = new DateOnly(1946, 1, 22), Adresse = new Adresse { Numero = "14", Rue = "Rue St-George", Ville = "Moncton", Province = "NB", CodePostal = "E1C2C2" }, Docteur = "Dr. Brown", NumeroTelephoneDocteur = "506-555-6666" });
        if (!Has("michel.robichaud@proconnect.local"))
            toAddUsers.Add(new Aine { Nom = "Robichaud", Prenom = "Michel", Telephone = "333-333-1006", Email = "michel.robichaud@proconnect.local", PasswordHash = "temp", DateNaissance = new DateOnly(1940, 9, 5), Adresse = new Adresse { Numero = "200", Rue = "Rue Mountain", Ville = "Moncton", Province = "NB", CodePostal = "E1C3C3" }, Docteur = "Dr. White", NumeroTelephoneDocteur = "506-777-8888" });
        if (!Has("brice.kamla@proconnect.local"))
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

        // Pour permettre aux comptes "standard" de l'équipe de surveiller des aînés via PartageSuivi,
        // on les force en type ProcheAidant (TPH discriminator) par email.
        await db.Database.ExecuteSqlInterpolatedAsync($"""
            UPDATE users
            SET type = 'ProcheAidant'
            WHERE lower(email) IN (
              'fabrice@proconnect.local',
              'kayleb@proconnect.local',
              'perez@proconnect.local',
              'grace@proconnect.local'
            );
            """, ct);

        var aines = await db.Aines.AsNoTracking().OrderBy(a => a.Id).ToListAsync(ct);
        if (aines.Count > 0)
        {
            var sig = 1;
            foreach (var a in aines)
            {
                var existing = await db.Medicaments.AsNoTracking().CountAsync(m => m.AineId == a.Id, ct);
                if (existing >= 5) continue;

                var meds = new List<Medicament>
                {
                    new() { Nom = "Vitamine D", Marque = "D-Vit", Dosage = "1000 MG", Frequence = "1x/jour", UrlPhoto = Unsplash("vitamin pills", sig++), AineId = a.Id, IsActive = true, IsDeleted = false },
                    new() { Nom = "Aspirine", Marque = "Bayer", Dosage = "81 MG", Frequence = "1x/jour", UrlPhoto = Unsplash("medicine bottle", sig++), AineId = a.Id, IsActive = true, IsDeleted = false },
                    new() { Nom = "Metformine", Marque = "Generic", Dosage = "500 MG", Frequence = "2x/jour", UrlPhoto = Unsplash("pharmacy pills", sig++), AineId = a.Id, IsActive = true, IsDeleted = false },
                    new() { Nom = "Atorvastatine", Marque = "Generic", Dosage = "20 MG", Frequence = "1x/jour", UrlPhoto = Unsplash("tablets", sig++), AineId = a.Id, IsActive = true, IsDeleted = false },
                    new() { Nom = "Lisinopril", Marque = "Generic", Dosage = "10 MG", Frequence = "1x/jour", UrlPhoto = Unsplash("capsules", sig++), AineId = a.Id, IsActive = true, IsDeleted = false }
                };

                db.Medicaments.AddRange(meds.Take(Math.Max(0, 5 - existing)));
            }
        }

        if (aines.Count > 0)
        {
            foreach (var a in aines)
            {
                var existing = await db.RendezVousMedicaux.AsNoTracking().CountAsync(r => r.AineId == a.Id, ct);
                if (existing >= 2) continue;

                db.RendezVousMedicaux.AddRange(
                    new RendezVousMedical
                    {
                        DateHeure = DateTime.UtcNow.AddDays(7),
                        Lieu = new Adresse { Numero = "99", Rue = "Rue Clinique", Ville = a.Adresse?.Ville ?? "Moncton", Province = "NB", CodePostal = "E1A 9A9" },
                        Docteur = "Généraliste",
                        Notes = "Contrôle",
                        AineId = a.Id
                    },
                    new RendezVousMedical
                    {
                        DateHeure = DateTime.UtcNow.AddDays(30),
                        Lieu = new Adresse { Numero = "101", Rue = "Boulevard Santé", Ville = a.Adresse?.Ville ?? "Moncton", Province = "NB", CodePostal = "E1A 8B8" },
                        Docteur = "Spécialiste",
                        Notes = "Suivi",
                        AineId = a.Id
                    }
                );
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

        {
            // Aidants principaux (mêmes emails que les comptes de l'équipe)
            var paFabriceMain = await db.ProchesAidants.AsNoTracking().FirstOrDefaultAsync(p => p.Email == "fabrice@proconnect.local", ct);
            var paKaylebMain = await db.ProchesAidants.AsNoTracking().FirstOrDefaultAsync(p => p.Email == "kayleb@proconnect.local", ct);
            var paPerezMain = await db.ProchesAidants.AsNoTracking().FirstOrDefaultAsync(p => p.Email == "perez@proconnect.local", ct);
            var paGraceMain = await db.ProchesAidants.AsNoTracking().FirstOrDefaultAsync(p => p.Email == "grace@proconnect.local", ct);

            // Aidants "du groupe" (emails *.aidant@...)
            var paFabriceGroup = await db.ProchesAidants.AsNoTracking().FirstOrDefaultAsync(p => p.Email == "fabrice.aidant@proconnect.local", ct);
            var paKaylebGroup = await db.ProchesAidants.AsNoTracking().FirstOrDefaultAsync(p => p.Email == "kayleb.aidant@proconnect.local", ct);
            var paPerezGroup = await db.ProchesAidants.AsNoTracking().FirstOrDefaultAsync(p => p.Email == "perez.aidant@proconnect.local", ct);
            var paGraceGroup = await db.ProchesAidants.AsNoTracking().FirstOrDefaultAsync(p => p.Email == "grace.aidant@proconnect.local", ct);

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

            async Task EnsureLinkAsync(ProcheAidant aidant, Aine aine, string relation, string autorisation)
            {
                var exists = await db.PartagesSuivi.AsNoTracking().AnyAsync(p =>
                    p.ProcheAidantId == aidant.Id && p.AineId == aine.Id, ct);
                if (exists) return;
                db.PartagesSuivi.Add(new PartageSuivi
                {
                    Autorisation = autorisation,
                    Relation = relation,
                    AineId = aine.Id,
                    ProcheAidantId = aidant.Id
                });
            }

            async Task Ensure2Async(ProcheAidant? aidant, int startIndex, string relation, string autorisation)
            {
                if (aidant == null || aines.Count == 0) return;
                for (var i = 0; i < 2; i++)
                {
                    var idx = Math.Min(startIndex + i, aines.Count - 1);
                    await EnsureLinkAsync(aidant, aines[idx], relation, autorisation);
                }
            }

            // Max 2 aînés à suivre par proche aidant (cas de test)
            await Ensure2Async(paFabriceMain, 0, "Proche", "Ecriture");
            await Ensure2Async(paKaylebMain, 2, "Ami", "Lecture");
            await Ensure2Async(paPerezMain, 4, "Frère", "Lecture");
            await Ensure2Async(paGraceMain, 6, "Fille", "Ecriture");

            // Les comptes *.aidant@... suivent aussi des aînés (max 2)
            await Ensure2Async(paFabriceGroup, 0, "Proche", "Lecture");
            await Ensure2Async(paKaylebGroup, 2, "Ami", "Lecture");
            await Ensure2Async(paPerezGroup, 4, "Frère", "Lecture");
            await Ensure2Async(paGraceGroup, 6, "Fille", "Lecture");
        }

        await db.SaveChangesAsync(ct);
    }
}