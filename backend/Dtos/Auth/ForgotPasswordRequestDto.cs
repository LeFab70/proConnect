// DTO pour la demande de réinitialisation de mot de passe
using System.ComponentModel.DataAnnotations; // Utilisation de DataAnnotations pour la validation des données

namespace backend.Dtos.Auth; 

public class ForgotPasswordRequestDto
{
    [Required(ErrorMessage = "L'email est obligatoire.")] // Validation pour s'assurer que l'email est fourni
    [EmailAddress(ErrorMessage = "L'email n'est pas valide.")] // Validation pour s'assurer que l'email est dans un format valide
    public required string Email { get; set; } // Propriété pour stocker l'email de l'utilisateur qui a oublié son mot de passe
}