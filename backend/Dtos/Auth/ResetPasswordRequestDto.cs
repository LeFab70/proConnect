using System.ComponentModel.DataAnnotations;

namespace backend.Dtos.Auth;

public class ResetPasswordRequestDto
{
    [Required(ErrorMessage = "Le token est obligatoire.")]
    public required string Token { get; set; }

    [Required(ErrorMessage = "Le nouveau mot de passe est obligatoire.")]
    [MinLength(8, ErrorMessage = "Le mot de passe doit contenir au moins 8 caractères.")]
    [MaxLength(200, ErrorMessage = "Le mot de passe ne doit pas dépasser 200 caractères.")]
    public required string NewPassword { get; set; }
}

