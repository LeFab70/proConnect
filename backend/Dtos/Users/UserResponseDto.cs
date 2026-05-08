namespace backend.Dtos.Users;

using backend.Dtos.Adresse;

public class UserResponseDto
{
    public long Id { get; set; }
    public required string Nom { get; set; }
    public required string Prenom { get; set; }
    public required string Telephone { get; set; }
    public required string Email { get; set; }
    public AdresseDto? Adresse { get; set; }
    public string? Type { get; set; } // "Aine" | "ProcheAidant" | "User"
}

