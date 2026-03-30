namespace backend.Dtos.Users;

public class UserResponseDto
{
    public long Id { get; set; }
    public required string Nom { get; set; }
    public required string Prenom { get; set; }
    public required string Telephone { get; set; }
    public required string Email { get; set; }
    public string? Role { get; set; }
}

