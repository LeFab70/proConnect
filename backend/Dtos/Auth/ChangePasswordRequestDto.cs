using System.ComponentModel.DataAnnotations;

namespace backend.Dtos.Auth;

public class ChangePasswordRequestDto
{
    [Required]
    public required string CurrentPassword { get; set; }

    [Required]
    [MinLength(8)]
    public required string NewPassword { get; set; }
}
