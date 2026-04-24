// DTO pour la réinitialisation du mot de passe
using System.ComponentModel.DataAnnotations; // Utilisé pour valider les données d'entrée lors de la réinitialisation du mot de passe

namespace backend.Dtos.Auth;

public class ResetPasswordRequestDto
{
    [Required(ErrorMessage = "Le token est obligatoire.")] // Le token de réinitialisation du mot de passe
    public required string Token { get; set; } // Le token passer dans l'URL de réinitialisation du mot de passe

    [Required(ErrorMessage = "Le nouveau mot de passe est obligatoire.")] // Le nouveau mot de passe que l'utilisateur souhaite définir
    [MinLength(8, ErrorMessage = "Le mot de passe doit contenir au moins 8 caractères.")] // Le mot de passe doit contenir au moins 8 caractères
    [MaxLength(200, ErrorMessage = "Le mot de passe ne doit pas dépasser 200 caractères.")] // Le mot de passe ne doit pas dépasser 200 caractères
    public required string NewPassword { get; set; } // Le nouveau mot de passe que l'utilisateur souhaite définir
}