namespace backend.Models;

// Modèle représentant un aîné
public class Aine
{
    public long Id { get; set; } // Identifiant unique de l'aîné
    public required string Nom { get; set; } // Nom de l'aîné
    public required string Prenom { get; set; } // Prénom de l'aîné
    public required string Telephone { get; set; } // Téléphone de l'aîné
    public required string Email { get; set; } // Email de l'aîné
    public DateOnly DateNaissance { get; set; } // Date de naissance de l'aîné
    public required string Adresse { get; set; } // Adresse de l'aîné
    public string Docteur { get; set; } // Nom du médecin de l'aîné
    public string NumeroTelephoneDocteur { get; set; } // Numéro de téléphone du médecin de l'aîné
}