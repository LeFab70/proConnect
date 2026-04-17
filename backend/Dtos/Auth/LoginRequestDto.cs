using System.ComponentModel.DataAnnotations;

namespace backend.Dtos.Auth;

public class LoginRequestDto
{
    [Required(ErrorMessage = "L'email est obligatoire.")]
    [EmailAddress(ErrorMessage = "L'email n'est pas valide.")]
    public required string Email { get; set; }

    [Required(ErrorMessage = "Le mot de passe est obligatoire.")]
    public required string Password { get; set; }
}

