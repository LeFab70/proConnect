using backend.Models;
using Microsoft.EntityFrameworkCore;

namespace backend.Infrastructure;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<User> Users => Set<User>();
    public DbSet<StandardUser> StandardUsers => Set<StandardUser>();
    public DbSet<Aine> Aines => Set<Aine>();
    public DbSet<ProcheAidant> ProchesAidants => Set<ProcheAidant>();
    public DbSet<Medicament> Medicaments => Set<Medicament>();
    public DbSet<RendezVousMedical> RendezVousMedicaux => Set<RendezVousMedical>();
    public DbSet<Rappel> Rappels => Set<Rappel>();
    public DbSet<CalendrierCommunautaire> CalendriersCommunautaires => Set<CalendrierCommunautaire>();
    public DbSet<ActiviteCommunautaire> ActivitesCommunautaires => Set<ActiviteCommunautaire>();
    public DbSet<PartageSuivi> PartagesSuivi => Set<PartageSuivi>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<User>(e =>
        {
            e.ToTable("users");
            e.HasKey(x => x.Id);
            e.HasDiscriminator<string>("type")
                .HasValue<StandardUser>("User")
                .HasValue<Aine>("Aine")
                .HasValue<ProcheAidant>("ProcheAidant");
            e.Property<string>("type").HasColumnName("type");
            e.Property(x => x.Nom).HasColumnName("nom");
            e.Property(x => x.Prenom).HasColumnName("prenom");
            e.Property(x => x.Telephone).HasColumnName("telephone");
            e.Property(x => x.Email).HasColumnName("email");
            e.OwnsOne(x => x.Adresse, adresse =>
            {
                adresse.Property(a => a.Numero).HasColumnName("lieu_numero");
                adresse.Property(a => a.Rue).HasColumnName("lieu_rue");
                adresse.Property(a => a.Ville).HasColumnName("lieu_ville");
                adresse.Property(a => a.CodePostal).HasColumnName("lieu_code_postal");
                adresse.Property(a => a.Province).HasColumnName("lieu_province");
            });
            e.Navigation(x => x.Adresse).IsRequired(false);
            e.Property(x => x.PasswordHash).HasColumnName("password_hash");
            e.Property(x => x.PasswordResetTokenHash).HasColumnName("password_reset_token_hash");
            e.Property(x => x.PasswordResetTokenExpiresAtUtc).HasColumnName("password_reset_token_expires_at_utc");
            e.HasIndex(x => x.Email).IsUnique();
        });

        modelBuilder.Entity<Aine>(e =>
        {
            e.Property(x => x.DateNaissance).HasColumnName("date_naissance");
            e.Property(x => x.Docteur).HasColumnName("docteur");
            e.Property(x => x.NumeroTelephoneDocteur).HasColumnName("numero_telephone_docteur");
        });

        modelBuilder.Entity<ProcheAidant>(_ => { });

        modelBuilder.Entity<Medicament>(e =>
        {
            e.ToTable("medicaments");
            e.HasKey(x => x.Id);
            e.Property(x => x.Nom).HasColumnName("nom");
            e.Property(x => x.Marque).HasColumnName("marque");
            e.Property(x => x.Dosage).HasColumnName("dosage");
            e.Property(x => x.Frequence).HasColumnName("frequence");
            e.Property(x => x.UrlPhoto).HasColumnName("url_photo");
            e.Property(x => x.AineId).HasColumnName("aine_id");
            e.Property(x => x.IsActive).HasColumnName("is_active");
            e.Property(x => x.IsDeleted).HasColumnName("is_deleted");
        });

        modelBuilder.Entity<RendezVousMedical>(e =>
        {
            e.ToTable("rendez_vous_medicaux");
            e.HasKey(x => x.Id);
            e.Property(x => x.DateHeure).HasColumnName("date_heure");
            e.OwnsOne(x => x.Lieu, adresse =>
            {
                adresse.Property(a => a.Numero).HasColumnName("lieu_numero");
                adresse.Property(a => a.Rue).HasColumnName("lieu_rue");
                adresse.Property(a => a.Ville).HasColumnName("lieu_ville");
                adresse.Property(a => a.CodePostal).HasColumnName("lieu_code_postal");
                adresse.Property(a => a.Province).HasColumnName("lieu_province");
            });
            e.Property(x => x.Docteur).HasColumnName("docteur");
            e.Property(x => x.Notes).HasColumnName("notes");
            e.Property(x => x.AineId).HasColumnName("aine_id");
        });

        modelBuilder.Entity<Rappel>(e =>
        {
            e.ToTable("rappels");
            e.HasKey(x => x.Id);
            e.Property(x => x.DateDebut).HasColumnName("date_debut");
            e.Property(x => x.HeureDebut).HasColumnName("heure_debut");
            e.Property(x => x.MinutesAvantRappel).HasColumnName("minutes_avant_rappel");
            e.Property(x => x.Type).HasColumnName("type");
            e.Property(x => x.Actif).HasColumnName("actif");
            e.Property(x => x.MedicamentId).HasColumnName("medicament_id");
            e.Property(x => x.RendezVousMedicalId).HasColumnName("rendez_vous_medical_id");
        });

        modelBuilder.Entity<CalendrierCommunautaire>(e =>
        {
            e.ToTable("calendriers_communautaires");
            e.HasKey(x => x.Id);
            e.Property(x => x.Region).HasColumnName("region");
        });

        modelBuilder.Entity<ActiviteCommunautaire>(e =>
        {
            e.ToTable("activites_communautaires");
            e.HasKey(x => x.Id);
            e.Property(x => x.Titre).HasColumnName("titre");
            e.Property(x => x.Description).HasColumnName("description");
            e.Property(x => x.DateHeure).HasColumnName("date_heure");
            e.OwnsOne(x => x.Lieu, adresse =>
            {
                adresse.Property(a => a.Numero).HasColumnName("lieu_numero");
                adresse.Property(a => a.Rue).HasColumnName("lieu_rue");
                adresse.Property(a => a.Ville).HasColumnName("lieu_ville");
                adresse.Property(a => a.CodePostal).HasColumnName("lieu_code_postal");
                adresse.Property(a => a.Province).HasColumnName("lieu_province");
            });
            e.Property(x => x.CalendrierCommunautaireId).HasColumnName("calendrier_communautaire_id");
        });

        modelBuilder.Entity<PartageSuivi>(e =>
        {
            e.ToTable("partages_suivi");
            e.HasKey(x => x.Id);
            e.Property(x => x.Autorisation).HasColumnName("autorisation");
            e.Property(x => x.Relation).HasColumnName("relation");
            e.Property(x => x.AineId).HasColumnName("aine_id");
            e.Property(x => x.ProcheAidantId).HasColumnName("proche_aidant_id");
            e.Property(x => x.ProcheEmail).HasColumnName("proche_email");
            e.Property(x => x.Statut).HasColumnName("statut");
            e.Property(x => x.CreatedAtUtc).HasColumnName("created_at_utc");
        });
    }
}
