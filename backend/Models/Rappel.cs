namespace backend.Models;

// Modèle de données pour représenter un rappel (médicament ou rendez-vous médical)
public class Rappel
{
    public long Id { get; set; } // Clé primaire
    public DateTime DateHeure { get; set; } // Date et heure du rappel
    public required string Type { get; set; } // ex: "Medicament", "RendezVous"
    public bool Actif { get; set; } // Indique si le rappel est actif ou non
    public long? MedicamentId { get; set; } // Clé étrangère vers Medicament (nullable)
    public long? RendezVousMedicalId { get; set; } // Clé étrangère vers RendezVousMedical (nullable)
}