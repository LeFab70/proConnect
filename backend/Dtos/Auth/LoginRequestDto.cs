// DTO pour la requête de connexion
using System.ComponentModel.DataAnnotations; // Utilisation de DataAnnotations pour la validation des données

namespace backend.Dtos.Auth;

public class LoginRequestDto
{
    [Required(ErrorMessage = "L'email est obligatoire.")] // Validation pour s'assurer que l'email est fourni
    [EmailAddress(ErrorMessage = "L'email n'est pas valide.")] // Validation pour s'assurer que l'email est dans un format valide
    public required string Email { get; set; } // Propriété pour stocker l'email de l'utilisateur qui tente de se connecter

    [Required(ErrorMessage = "Le mot de passe est obligatoire.")] // Validation pour s'assurer que le mot de passe est fourni
    public required string Password { get; set; } // Propriété pour stocker le mot de passe de l'utilisateur qui tente de se connecter
}