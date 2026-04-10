using System.ComponentModel.DataAnnotations;

namespace backend.Dtos.Auth;

public class TokenRequestDto
{
    [Required(ErrorMessage = "L'email est obligatoire.")]
    [EmailAddress(ErrorMessage = "L'email n'est pas valide.")]
    public required string Email { get; set; }

    [Required(ErrorMessage = "Le rôle est obligatoire.")]
    [MinLength(3, ErrorMessage = "Le rôle doit contenir au moins 3 caractères.")]
    [MaxLength(32, ErrorMessage = "Le rôle ne doit pas dépasser 32 caractères.")]
    public required string Role { get; set; } // "Aine" | "ProcheAidant" | "Admin"

    [Required(ErrorMessage = "Le secret est obligatoire.")]
    [MinLength(8, ErrorMessage = "Le secret doit contenir au moins 8 caractères.")]
    public required string Secret { get; set; } // doit matcher DEV_AUTH_SECRET
}

