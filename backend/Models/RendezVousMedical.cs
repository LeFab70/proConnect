namespace backend.Models;

// Modèle de données pour représenter un rendez-vous médical d'un aîné
public class RendezVousMedical
{
    public long Id { get; set; } // Clé primaire
    public DateTime DateHeure { get; set; } // Date et heure du rendez-vous
    public required Adresse Lieu { get; set; } // Lieu du rendez-vous
    public required string Docteur { get; set; } // Docteur consulté (ex: Cardiologue, Généraliste, etc.)
    public string? Notes { get; set; } // Notes supplémentaires sur le rendez-vous
    public long AineId { get; set; } // Clé étrangère vers Aine
}