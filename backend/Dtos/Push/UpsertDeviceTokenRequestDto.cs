using System.ComponentModel.DataAnnotations;

namespace backend.Dtos.Push;

public class UpsertDeviceTokenRequestDto
{
    [Required(ErrorMessage = "Token est obligatoire.")]
    [MinLength(20, ErrorMessage = "Token invalide.")]
    public required string Token { get; set; }

    [MaxLength(20)]
    public string? Platform { get; set; } // "android" | "ios"
}

