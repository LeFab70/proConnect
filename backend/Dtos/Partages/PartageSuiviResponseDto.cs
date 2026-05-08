// DTO de réponse pour le suivi d'un partage
namespace backend.Dtos.Partages;

public class PartageSuiviResponseDto
{
    public long Id { get; set; } // ID du partage
    public required string Autorisation { get; set; } // Autorisation du partage (ex: "Acceptée", "Refusée")
    public required string Relation { get; set; } // Relation du proche aidant avec l'aîné (ex: "Fils", "Fille", "Conjoint", etc.)
    public long AineId { get; set; } // ID de l'aîné associé au partage
    public long? ProcheAidantId { get; set; } // ID du proche/aidant associé au partage
    public string? ProcheEmail { get; set; }
    public required string Statut { get; set; } // enAttente | actif | refuse
    public DateTime CreatedAtUtc { get; set; }
}