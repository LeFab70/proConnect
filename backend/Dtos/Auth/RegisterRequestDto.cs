// DTO pour la requête d'inscription
using System.ComponentModel.DataAnnotations; // Utilisation de DataAnnotations pour la validation des données

namespace backend.Dtos.Auth;

public class RegisterRequestDto
{
    [Required(ErrorMessage = "Le nom est obligatoire.")] // Validation pour s'assurer que le nom est fourni
    [MinLength(1, ErrorMessage = "Le nom ne peut pas être vide.")] // Validation pour s'assurer que le nom n'est pas vide
    [MaxLength(100, ErrorMessage = "Le nom ne doit pas dépasser 100 caractères.")] // Validation pour s'assurer que le nom ne dépasse pas 100 caractères
    public required string Nom { get; set; } // Nom obligatoire pour user, entre 1 et 100 caractères

    [Required(ErrorMessage = "Le prénom est obligatoire.")] // Validation pour s'assurer que le prénom est fourni
    [MinLength(1, ErrorMessage = "Le prénom ne peut pas être vide.")] // Validation pour s'assurer que le prénom n'est pas vide
    [MaxLength(100, ErrorMessage = "Le prénom ne doit pas dépasser 100 caractères.")] // Validation pour s'assurer que le prénom ne dépasse pas 100 caractères
    public required string Prenom { get; set; } // Prénom obligatoire pour user, entre 1 et 100 caractères

    [Required(ErrorMessage = "Le téléphone est obligatoire.")] // Validation pour s'assurer que le téléphone est fourni
    [Phone(ErrorMessage = "Le téléphone n'est pas valide.")] // Validation pour s'assurer que le téléphone est dans un format valide
    [MaxLength(30, ErrorMessage = "Le téléphone ne doit pas dépasser 30 caractères.")] // Validation pour s'assurer que le téléphone ne dépasse pas 30 caractères
    public required string Telephone { get; set; } // Téléphone obligatoire pour user, format valide, max 30 caractères

    [Required(ErrorMessage = "L'email est obligatoire.")] // Validation pour s'assurer que l'email est fourni
    [EmailAddress(ErrorMessage = "L'email n'est pas valide.")] // Validation pour s'assurer que l'email est dans un format valide
    [MaxLength(200, ErrorMessage = "L'email ne doit pas dépasser 200 caractères.")] // Validation pour s'assurer que l'email ne dépasse pas 200 caractères
    public required string Email { get; set; } // Email obligatoire pour user, format valide, max 200 caractères

    [Required(ErrorMessage = "Le mot de passe est obligatoire.")] // Validation pour s'assurer que le mot de passe est fourni
    [MinLength(8, ErrorMessage = "Le mot de passe doit contenir au moins 8 caractères.")] // Validation pour s'assurer que le mot de passe contient au moins 8 caractères
    [MaxLength(200, ErrorMessage = "Le mot de passe ne doit pas dépasser 200 caractères.")] // Validation pour s'assurer que le mot de passe ne dépasse pas 200 caractères
    public required string Password { get; set; } // Mot de passe obligatoire pour user, entre 8 et 200 caractères

    /// <summary>
    /// Optionnel. Valeurs attendues côté app: "AINE" ou "AIDANT".
    /// Si absent: création par défaut en ProcheAidant.
    /// </summary>
    public string? Role { get; set; }

    // Champs spécifiques Aîné (requis uniquement si Role == "AINE")
    public DateOnly? DateNaissance { get; set; }
    public backend.Dtos.Adresse.AdresseDto? Adresse { get; set; }
    public string? Docteur { get; set; }
    public string? NumeroTelephoneDocteur { get; set; }
}