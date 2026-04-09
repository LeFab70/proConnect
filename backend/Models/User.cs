namespace backend.Models;

// Modèle de données pour représenter un utilisateur (Aîné, Proche Aidant, Admin)
public class User
{
    public long Id { get; set; } // Clé primaire
    public required string Nom { get; set; } // Nom de famille
    public required string Prenom { get; set; } // Prénom
    public required string Telephone { get; set; } // Numéro de téléphone
    public required string Email { get; set; } // Adresse e-mail
    public string? Role { get; set; } // ex: "Aine", "ProcheAidant", "Admin"
}