// DTO pour la création ou la mise à jour d'un aîné (Upsert = Update or Insert)
using System.ComponentModel.DataAnnotations; // Utilisation de DataAnnotations pour la validation des propriétés (Messages d'erreur, contraintes de longueur, etc.)
using backend.Dtos.Adresse; // Utilisation de l'AdresseDto pour la propriété Adresse de l'aîné (Pour ne pas l'ajouter dans la base de données comme classe séparée, mais plutôt comme une propriété complexe de l'aîné)

namespace backend.Dtos.Aines;

public class UpsertAineRequestDto
{
    [Required(ErrorMessage = "Le nom est obligatoire.")] // Nom de l'aîné obligatoire
    [MinLength(1, ErrorMessage = "Le nom ne peut pas être vide.")] // Nom de l'aîné doit contenir au moins 1 caractère
    [MaxLength(100, ErrorMessage = "Le nom ne doit pas dépasser 100 caractères.")] // Nom de l'aîné ne doit pas dépasser 100 caractères
    public required string Nom { get; set; } // Nom de l'aîné obligatoire, entre 1 et 100 caractères

    [Required(ErrorMessage = "Le prénom est obligatoire.")] // Prénom de l'aîné obligatoire
    [MinLength(1, ErrorMessage = "Le prénom ne peut pas être vide.")] // Prénom de l'aîné doit contenir au moins 1 caractère
    [MaxLength(100, ErrorMessage = "Le prénom ne doit pas dépasser 100 caractères.")] // Prénom de l'aîné ne doit pas dépasser 100 caractères
    public required string Prenom { get; set; } // Prénom de l'aîné obligatoire, entre 1 et 100 caractères

    [Required(ErrorMessage = "Le téléphone est obligatoire.")] // Téléphone de l'aîné obligatoire
    [Phone(ErrorMessage = "Le téléphone n'est pas valide.")] // Téléphone de l'aîné doit être un numéro de téléphone valide
    [MaxLength(30, ErrorMessage = "Le téléphone ne doit pas dépasser 30 caractères.")] // Téléphone de l'aîné ne doit pas dépasser 30 caractères
    public required string Telephone { get; set; } // Téléphone de l'aîné obligatoire, doit être un numéro de téléphone valide, ne doit pas dépasser 30 caractères

    [Required(ErrorMessage = "L'email est obligatoire.")] // Email de l'aîné obligatoire
    [EmailAddress(ErrorMessage = "L'email n'est pas valide.")] // Email de l'aîné doit être une adresse email valide
    [MaxLength(200, ErrorMessage = "L'email ne doit pas dépasser 200 caractères.")] // Email de l'aîné ne doit pas dépasser 200 caractères
    public required string Email { get; set; } // Email de l'aîné obligatoire, doit être une adresse email valide, ne doit pas dépasser 200 caractères

    [Required(ErrorMessage = "La date de naissance est obligatoire.")] // Date de naissance de l'aîné obligatoire
    public DateOnly DateNaissance { get; set; } // Date de naissance de l'aîné obligatoire

    [Required(ErrorMessage = "L'adresse est obligatoire.")] // Adresse de l'aîné obligatoire
    public required AdresseDto Adresse { get; set; } // Adresse de l'aîné obligatoire, doit être un objet AdresseDto (Pour ne pas l'ajouter dans la base de données comme classe séparée, mais plutôt comme une propriété complexe de l'aîné)

    [MaxLength(100, ErrorMessage = "Le nom du docteur ne doit pas dépasser 100 caractères.")] // Nom du docteur de l'aîné ne doit pas dépasser 100 caractères
    public string Docteur { get; set; } = string.Empty; // Nom du docteur de l'aîné, ne doit pas dépasser 100 caractères
    
    [MaxLength(30, ErrorMessage = "Le numéro de téléphone du docteur ne doit pas dépasser 30 caractères.")] // Numéro de téléphone du docteur de l'aîné ne doit pas dépasser 30 caractères
    public string NumeroTelephoneDocteur { get; set; } = string.Empty; // Numéro de téléphone du docteur de l'aîné, ne doit pas dépasser 30 caractères
}