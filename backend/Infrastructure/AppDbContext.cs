// Contexte : AppDbContext.cs - Classe de contexte de base de données pour l'application, utilisant Entity Framework Core pour gérer les entités et les relations avec la base de données
using backend.Models;
using Microsoft.EntityFrameworkCore; // Importation de Entity Framework Core pour la gestion de la base de données, des entités et des migrations

namespace backend.Infrastructure;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    // Définition des DbSet pour chaque entité du modèle de données, permettant à Entity Framework Core de gérer les opérations CRUD sur ces entités dans la base de données
    public DbSet<User> Users => Set<User>(); // DbSet pour l'entité User, qui est la classe de base pour les différents types d'utilisateurs (StandardUser, Aine, ProcheAidant) grâce à l'héritage TPH (Table Per Hierarchy)
    public DbSet<StandardUser> StandardUsers => Set<StandardUser>(); // DbSet pour les utilisateurs de type StandardUser, qui hérite de User (Non utiliser presentement, mais défini pour la clarté et la possibilité de requêter spécifiquement les utilisateurs standard)
    public DbSet<Aine> Aines => Set<Aine>(); // DbSet pour les utilisateurs de type Aine, qui hérite de User (Représente les aînés dans le système)
    public DbSet<ProcheAidant> ProchesAidants => Set<ProcheAidant>(); // DbSet pour les utilisateurs de type ProcheAidant, qui hérite de User (Représente les proches aidants dans le système)
    public DbSet<Medicament> Medicaments => Set<Medicament>(); // DbSet pour l'entité Medicament, qui représente les médicaments prescrits aux aînés
    public DbSet<RendezVousMedical> RendezVousMedicaux => Set<RendezVousMedical>(); // DbSet pour l'entité RendezVousMedical, qui représente les rendez-vous médicaux des aînés
    public DbSet<Rappel> Rappels => Set<Rappel>(); // DbSet pour l'entité Rappel, qui représente les rappels de prise de médicaments ou de rendez-vous médicaux pour les aînés
    public DbSet<CalendrierCommunautaire> CalendriersCommunautaires => Set<CalendrierCommunautaire>(); // DbSet pour l'entité CalendrierCommunautaire, qui représente les calendriers communautaires auxquels les activités communautaires sont associées
    public DbSet<ActiviteCommunautaire> ActivitesCommunautaires => Set<ActiviteCommunautaire>(); // DbSet pour l'entité ActiviteCommunautaire, qui représente les activités communautaires créées par HuggingFace AI pour être partagées dans les calendriers communautaires
    public DbSet<PartageSuivi> PartagesSuivi => Set<PartageSuivi>(); // DbSet pour l'entité PartageSuivi, qui représente les partages de suivi entre les aînés et les proches aidants, avec des autorisations spécifiques

    // Configuration des entités et de leurs relations dans la base de données à l'aide de Fluent API dans la méthode OnModelCreating, qui est appelée lors de la création du modèle de données par Entity Framework Core
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Configuration de l'entité User et de ses dérivés (StandardUser, Aine, ProcheAidant) en utilisant l'héritage TPH (Table Per Hierarchy), où toutes les propriétés des classes dérivées sont stockées dans la même table "users" avec une colonne discriminante "type" pour différencier les types d'utilisateurs
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
            e.Property(x => x.PasswordHash).HasColumnName("password_hash");
            e.Property(x => x.PasswordResetTokenHash).HasColumnName("password_reset_token_hash");
            e.Property(x => x.PasswordResetTokenExpiresAtUtc).HasColumnName("password_reset_token_expires_at_utc");
            e.HasIndex(x => x.Email).IsUnique();
        });

        // Configuration spécifique pour les propriétés des classes dérivées Aine et ProcheAidant, qui restent dans la même table "users" grâce à l'héritage TPH, mais avec des colonnes spécifiques pour chaque type d'utilisateur
        modelBuilder.Entity<Aine>(e =>
        {
            // Ajout des propriétés spécifiques à Aine dans la même table "users" grâce à l'héritage TPH
            e.Property(x => x.DateNaissance).HasColumnName("date_naissance");
            e.OwnsOne(x => x.Adresse, adresse =>
            {
                adresse.Property(a => a.Numero).HasColumnName("lieu_numero");
                adresse.Property(a => a.Rue).HasColumnName("lieu_rue");
                adresse.Property(a => a.Ville).HasColumnName("lieu_ville");
                adresse.Property(a => a.CodePostal).HasColumnName("lieu_code_postal");
                adresse.Property(a => a.Province).HasColumnName("lieu_province");
            });
            e.Property(x => x.Docteur).HasColumnName("docteur");
            e.Property(x => x.NumeroTelephoneDocteur).HasColumnName("numero_telephone_docteur");
        });

        // Configuration spécifique pour les propriétés des classes dérivées Aine et ProcheAidant, qui restent dans la même table "users" grâce à l'héritage TPH, mais avec des colonnes spécifiques pour chaque type d'utilisateur
        modelBuilder.Entity<ProcheAidant>(e =>
        {
            // Ajout des propriétés spécifiques à ProcheAidant dans la même table "users" grâce à l'héritage TPH
            
        });

        // Configuration de l'entité Medicament, qui représente les médicaments prescrits aux aînés, avec des propriétés telles que le nom, la marque, le dosage, la fréquence et une clé étrangère vers l'aîné auquel le médicament est associé
        modelBuilder.Entity<Medicament>(e =>
        {
            e.ToTable("medicaments");
            e.HasKey(x => x.Id);
            e.Property(x => x.Nom).HasColumnName("nom");
            e.Property(x => x.Marque).HasColumnName("marque");
            e.Property(x => x.Dosage).HasColumnName("dosage");
            e.Property(x => x.Frequence).HasColumnName("frequence");
            e.Property(x => x.AineId).HasColumnName("aine_id");
        });

        // Configuration de l'entité RendezVousMedical, qui représente les rendez-vous médicaux des aînés, avec des propriétés telles que la date et l'heure, le lieu, le docteur, des notes et une clé étrangère vers l'aîné auquel le rendez-vous est associé
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

        // Configuration de l'entité Rappel, qui représente les rappels de prise de médicaments ou de rendez-vous médicaux pour les aînés, avec des propriétés telles que la date et l'heure du rappel, le type (médicament ou rendez-vous), un indicateur d'activation, et des clés étrangères vers le médicament ou le rendez-vous médical associé
        modelBuilder.Entity<Rappel>(e =>
        {
            e.ToTable("rappels");
            e.HasKey(x => x.Id);
            e.Property(x => x.DateHeure).HasColumnName("date_heure");
            e.Property(x => x.Type).HasColumnName("type");
            e.Property(x => x.Actif).HasColumnName("actif");
            e.Property(x => x.MedicamentId).HasColumnName("medicament_id");
            e.Property(x => x.RendezVousMedicalId).HasColumnName("rendez_vous_medical_id");
        });

        // Configuration de l'entité CalendrierCommunautaire, qui représente les calendriers communautaires auxquels les activités communautaires sont associées, avec une propriété region pour identifier le calendrier
        modelBuilder.Entity<CalendrierCommunautaire>(e =>
        {
            e.ToTable("calendriers_communautaires");
            e.HasKey(x => x.Id);
            e.Property(x => x.Region).HasColumnName("region");
        });

        // Configuration de l'entité ActiviteCommunautaire, qui représente les activités communautaires créées par HuggingFace AI pour être partagées dans les calendriers communautaires, avec des propriétés telles que le titre, la description, la date et l'heure, le lieu (en tant que propriété complexe avec les détails de l'adresse), et une clé étrangère vers le calendrier communautaire auquel l'activité est associée
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

        // Configuration de l'entité PartageSuivi, qui représente les partages de suivi entre les aînés et les proches aidants, avec des propriétés telles que l'autorisation (lecture seule ou lecture/écriture), et des clés étrangères vers l'aîné et le proche aidant impliqués dans le partage
        modelBuilder.Entity<PartageSuivi>(e =>
        {
            e.ToTable("partages_suivi");
            e.HasKey(x => x.Id);
            e.Property(x => x.Autorisation).HasColumnName("autorisation");
            e.Property(x => x.Relation).HasColumnName("relation");
            e.Property(x => x.AineId).HasColumnName("aine_id");
            e.Property(x => x.ProcheAidantId).HasColumnName("proche_aidant_id");
        });
    }
}