namespace backend.Models;

// Modèle de données pour représenter le partage de suivi entre un aîné et un proche aidant (Plusieurs a Plusieurs)
public class PartageSuivi
{
    public long Id { get; set; } // Clé primaire
    public required string Autorisation { get; set; } // "Lecture", "Ecriture", etc.
    public long AineId { get; set; } // Clé étrangère vers Aine
    public long ProcheAidantId { get; set; } // Clé étrangère vers ProcheAidant
}