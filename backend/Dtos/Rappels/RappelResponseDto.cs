// DTO de réponse pour les rappels, utilisé pour envoyer les données des rappels au client
namespace backend.Dtos.Rappels;

public class RappelResponseDto
{
    public long Id { get; set; } // Identifiant unique du rappel
    public DateTime DateHeure { get; set; } // Date et heure du rappel
    public required string Type { get; set; } // Type de rappel (ex: "Médicament", "Rendez-vous médical")
    public bool Actif { get; set; } // Indique si le rappel est actif ou non
    public long? MedicamentId { get; set; } // Identifiant du médicament associé au rappel (si applicable)
    public long? RendezVousMedicalId { get; set; } // Identifiant du rendez-vous médical associé au rappel (si applicable)
}