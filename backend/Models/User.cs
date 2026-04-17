namespace backend.Models;

public abstract class User
{
    public long Id { get; set; }
    // Keycloak (ancien) — gardé en commentaire pour référence
    // public string? KeycloakId { get; set; } // claim "sub"

    public required string Nom { get; set; }
    public required string Prenom { get; set; }
    public required string Telephone { get; set; }
    public required string Email { get; set; }

    // Auth locale
    public required string PasswordHash { get; set; }
    public DateTime? PasswordResetTokenExpiresAtUtc { get; set; }
    public string? PasswordResetTokenHash { get; set; }
}