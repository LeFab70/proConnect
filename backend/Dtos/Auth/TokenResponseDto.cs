// DTO pour la réponse de génération de token d'authentification
namespace backend.Dtos.Auth;

public class TokenResponseDto
{
    public required string AccessToken { get; set; } // Le token d'accès généré
    public required string TokenType { get; set; } // "Bearer"
    public long ExpiresInSeconds { get; set; } // Durée de validité du token en secondes
}