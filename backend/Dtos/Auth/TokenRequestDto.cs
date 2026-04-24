// DTO pour la requête de génération de token d'authentification
using System.ComponentModel.DataAnnotations; // pour les annotations de validation des données

namespace backend.Dtos.Auth;

public class TokenRequestDto
{
    [Required(ErrorMessage = "L'email est obligatoire.")] // L'email est requis pour générer le token
    [EmailAddress(ErrorMessage = "L'email n'est pas valide.")] // L'email doit être dans un format valide
    public required string Email { get; set; } // L'email obligatoire et doit être valide

    [Required(ErrorMessage = "Le rôle est obligatoire.")] // Le rôle est requis pour générer le token
    [MinLength(3, ErrorMessage = "Le rôle doit contenir au moins 3 caractères.")] // Le rôle doit contenir au moins 3 caractères
    [MaxLength(32, ErrorMessage = "Le rôle ne doit pas dépasser 32 caractères.")] // Le rôle ne doit pas dépasser 32 caractères
    public required string Role { get; set; } // "Aine" | "ProcheAidant" | "Admin"

    [Required(ErrorMessage = "Le secret est obligatoire.")] // Le secret est requis pour générer le token
    [MinLength(8, ErrorMessage = "Le secret doit contenir au moins 8 caractères.")] // Le secret doit contenir au moins 8 caractères pour des raisons de sécurité
    public required string Secret { get; set; } // doit matcher DEV_AUTH_SECRET
}