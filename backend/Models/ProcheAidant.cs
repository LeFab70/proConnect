namespace backend.Models;

// Modèle de données pour représenter un proche aidant
public class ProcheAidant
{
    public long Id { get; set; } // Clé primaire
    public required string Nom { get; set; } // Nom de famille du proche aidant
    public required string Prenom { get; set; } // Prénom du proche aidant
    public required string Telephone { get; set; } // Numéro de téléphone du proche aidant
    public required string Email { get; set; } // Adresse e-mail du proche aidant
    public required string Relation { get; set; } // Relation avec l'aîné
}