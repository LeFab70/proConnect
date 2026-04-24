// DTO de réponse pour un aîné, utilisé pour envoyer les données d'un aîné
using backend.Dtos.Adresse; // Importation du DTO pour l'adresse, utilisé pour l'adresse de l'aîné (Pour ne pas l'ajouter dans la base de données comme classe séparée, mais plutôt comme une propriété complexe de l'aîné)

namespace backend.Dtos.Aines;

public class AineResponseDto
{
    public long Id { get; set; } // Identifiant de l'aîné
    public required string Nom { get; set; } // Nom de l'aîné
    public required string Prenom { get; set; } // Prénom de l'aîné
    public required string Telephone { get; set; } // Numéro de téléphone de l'aîné
    public required string Email { get; set; } // Adresse e-mail de l'aîné
    public DateOnly DateNaissance { get; set; } // Date de naissance de l'aîné
    public AdresseDto Adresse { get; set; } // Adresse de l'aîné
    public string Docteur { get; set; } = string.Empty; // Nom du docteur de l'aîné
    public string NumeroTelephoneDocteur { get; set; } = string.Empty; // Numéro de téléphone du docteur de l'aîné
}