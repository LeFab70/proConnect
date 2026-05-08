using System.Security.Cryptography;
using System.Text;
using backend.Dtos.Auth;
using backend.Infrastructure;
using backend.Models;
using backend.Services.Interfaces;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace backend.Services;

public class AuthService(AppDbContext db, IEmailService email) : IAuthService
{
    private readonly AppDbContext _db = db;
    private readonly IEmailService _email = email;
    private readonly PasswordHasher<User> _hasher = new();

    public async Task<TokenResponseDto> Register(RegisterRequestDto dto)
    {
        var exists = await _db.Users.AnyAsync(u => u.Email.ToLower() == dto.Email.ToLower());
        if (exists) throw new InvalidOperationException("Email already exists.");

        // Default behavior: a newly registered account is a ProcheAidant.
        // This matches the app's expectations (aidant by default) and the seed strategy.
        var user = new ProcheAidant
        {
            Nom = dto.Nom,
            Prenom = dto.Prenom,
            Telephone = dto.Telephone,
            Email = dto.Email,
            PasswordHash = "temp" // overwritten below
        };
        user.PasswordHash = _hasher.HashPassword(user, dto.Password);

        _db.Users.Add(user);
        await _db.SaveChangesAsync();

        return IssueJwt(user.Id, user.Email, roles: Array.Empty<string>());
    }

    public async Task<TokenResponseDto?> Login(LoginRequestDto dto)
    {
        var user = await _db.Users.FirstOrDefaultAsync(u => u.Email.ToLower() == dto.Email.ToLower());
        if (user == null) return null;

        var ok = _hasher.VerifyHashedPassword(user, user.PasswordHash, dto.Password);
        if (ok == PasswordVerificationResult.Failed) return null;

        return IssueJwt(user.Id, user.Email, roles: Array.Empty<string>());
    }

    public async Task RequestPasswordReset(ForgotPasswordRequestDto dto)
    {
        var user = await _db.Users.FirstOrDefaultAsync(u => u.Email.ToLower() == dto.Email.ToLower());
        // For security, always return success even if not found.
        if (user == null) return;

        var rawToken = GenerateToken();
        user.PasswordResetTokenExpiresAtUtc = DateTime.UtcNow.AddHours(1);
        user.PasswordResetTokenHash = Sha256(rawToken);
        await _db.SaveChangesAsync();

        var resetBaseUrl = Environment.GetEnvironmentVariable("RESET_PASSWORD__BASE_URL") ?? "http://localhost:3000/reset-password";
        var link = $"{resetBaseUrl}?token={Uri.EscapeDataString(rawToken)}";
        await _email.SendAsync(user.Email, "Reset password", $"Clique ici pour réinitialiser ton mot de passe:\n{link}\n\nCe lien expire dans 1 heure.");
    }

    public async Task<bool> ResetPassword(ResetPasswordRequestDto dto)
    {
        var tokenHash = Sha256(dto.Token);
        var user = await _db.Users.FirstOrDefaultAsync(u =>
            u.PasswordResetTokenHash == tokenHash &&
            u.PasswordResetTokenExpiresAtUtc != null &&
            u.PasswordResetTokenExpiresAtUtc > DateTime.UtcNow);

        if (user == null) return false;

        user.PasswordHash = _hasher.HashPassword(user, dto.NewPassword);
        user.PasswordResetTokenHash = null;
        user.PasswordResetTokenExpiresAtUtc = null;
        await _db.SaveChangesAsync();
        return true;
    }

    private static string GenerateToken()
    {
        var bytes = RandomNumberGenerator.GetBytes(32);
        return Convert.ToBase64String(bytes);
    }

    private static string Sha256(string input)
    {
        var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(input));
        return Convert.ToHexString(bytes);
    }

    private static TokenResponseDto IssueJwt(long userId, string email, string[] roles)
    {
        var jwtKey = Environment.GetEnvironmentVariable("JWT__Key")
                     ?? throw new InvalidOperationException("Missing env var: JWT__Key");
        var issuer = Environment.GetEnvironmentVariable("JWT__Issuer") ?? "ProConnectNB";
        var audience = Environment.GetEnvironmentVariable("JWT__Audience") ?? "ProConnectNB";
        var expiresMinutes = long.TryParse(Environment.GetEnvironmentVariable("JWT__ExpiresMinutes"), out var mins) ? mins : 120;

        var claims = new List<Claim>
        {
            new(ClaimTypes.NameIdentifier, userId.ToString()),
            new(ClaimTypes.Email, email)
        };
        foreach (var r in roles)
        {
            claims.Add(new Claim(ClaimTypes.Role, r));
        }

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
        var token = new JwtSecurityToken(
            issuer: issuer,
            audience: audience,
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(expiresMinutes),
            signingCredentials: creds
        );

        var accessToken = new JwtSecurityTokenHandler().WriteToken(token);
        return new TokenResponseDto
        {
            AccessToken = accessToken,
            TokenType = "Bearer",
            ExpiresInSeconds = expiresMinutes * 60
        };
    }
}

