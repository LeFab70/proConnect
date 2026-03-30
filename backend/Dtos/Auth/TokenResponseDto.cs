namespace backend.Dtos.Auth;

public class TokenResponseDto
{
    public required string AccessToken { get; set; }
    public required string TokenType { get; set; } // "Bearer"
    public long ExpiresInSeconds { get; set; }
}

