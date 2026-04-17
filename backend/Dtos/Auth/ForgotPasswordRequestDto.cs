using System.ComponentModel.DataAnnotations;

namespace backend.Dtos.Auth;

public class ForgotPasswordRequestDto
{
    [Required(ErrorMessage = "L'email est obligatoire.")]
    [EmailAddress(ErrorMessage = "L'email n'est pas valide.")]
    public required string Email { get; set; }
}

