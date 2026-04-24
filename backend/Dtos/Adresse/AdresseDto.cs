// DTO pour représenter une adresse

using System.ComponentModel.DataAnnotations; // Utilisation de DataAnnotations pour la validation des propriétés (Messages d'erreur, contraintes de longueur, etc.)

namespace backend.Dtos.Adresse; // Namespace pour les DTO liés à l'adresse

public class AdresseDto
{
    [Required(ErrorMessage = "Le numéro est obligatoire.")] // Numéro de rue obligatoire
    [MinLength(1, ErrorMessage = "Le numéro ne peut pas être vide.")] // Numéro de rue doit contenir au moins 1 caractère
    [MaxLength(10, ErrorMessage = "Le numéro ne doit pas dépasser 10 caractères.")] // Numéro de rue ne doit pas dépasser 10 caractères
    public required string Numero { get; set; } // Numéro de rue obligatoire, entre 1 et 10 caractères

    [Required(ErrorMessage = "La rue est obligatoire.")] // Rue obligatoire
    [MinLength(1, ErrorMessage = "La rue ne peut pas être vide.")] // Rue doit contenir au moins 1 caractère
    [MaxLength(100, ErrorMessage = "La rue ne doit pas dépasser 100 caractères.")] // Rue ne doit pas dépasser 100 caractères
    public required string Rue { get; set; } // Rue obligatoire, entre 1 et 100 caractères

    [Required(ErrorMessage = "La ville est obligatoire.")] // Ville obligatoire
    [MinLength(1, ErrorMessage = "La ville ne peut pas être vide.")] // Ville doit contenir au moins 1 caractère
    [MaxLength(100, ErrorMessage = "La ville ne doit pas dépasser 100 caractères.")] // Ville ne doit pas dépasser 100 caractères
    public required string Ville { get; set; } // Ville obligatoire, entre 1 et 100 caractères

    [Required(ErrorMessage = "Le code postal est obligatoire.")] // Code postal obligatoire
    [MinLength(3, ErrorMessage = "Le code postal doit contenir au moins 3 caractères.")] // Code postal doit contenir au moins 3 caractères
    [MaxLength(6, ErrorMessage = "Le code postal ne doit pas dépasser 6 caractères.")] // Code postal ne doit pas dépasser 6 caractères
    public required string CodePostal { get; set; } // Code postal obligatoire, entre 3 et 6 caractères

    [Required(ErrorMessage = "La province est obligatoire.")] // Province obligatoire
    [MinLength(1, ErrorMessage = "La province ne peut pas être vide.")] // Province doit contenir au moins 1 caractère
    [MaxLength(100, ErrorMessage = "La province ne doit pas dépasser 100 caractères.")] // Province ne doit pas dépasser 100 caractères
    public required string Province { get; set; } // Province obligatoire, entre 1 et 100 caractères
}