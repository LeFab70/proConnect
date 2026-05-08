// Modèle de données pour représenter le partage de suivi entre un aîné et un proche aidant (Plusieurs a Plusieurs)
namespace backend.Models;

public class PartageSuivi
{
    public long Id { get; set; } // Clé primaire
    public required string Autorisation { get; set; } // "Lecture", "Ecriture", etc.
    public required string Relation { get; set; } // Relation du proche aidant avec l'aîné (ex: "Fils", "Fille", "Conjoint", etc.)
    public long AineId { get; set; } // Clé étrangère vers Aine
    public long? ProcheAidantId { get; set; } // Clé étrangère vers ProcheAidant (nullable pour invitation par email)

    // Invitation par email si le compte proche aidant n'existe pas encore
    public string? ProcheEmail { get; set; }

    // "enAttente" | "actif" | "refuse"
    public string Statut { get; set; } = "enAttente";

    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
}