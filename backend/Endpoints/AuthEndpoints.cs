using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using backend.Dtos.Auth;
using backend.Infrastructure;
using Microsoft.IdentityModel.Tokens;

namespace backend.Endpoints;

public static class AuthEndpoints
{
    public static void MapAuthEndpoints(this WebApplication app)
    {
        app.MapPost("/api/auth/token", Token)
            .WithTags("Auth")
            .AllowAnonymous()
            .Produces<TokenResponseDto>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status401Unauthorized)
            .ProducesProblem(StatusCodes.Status500InternalServerError)
            .WithOpenApi(o =>
            {
                o.Summary = "Génère un JWT (dev)";
                o.Description = "Valide DEV_AUTH_SECRET puis retourne un JWT contenant Email + Role.";
                return o;
            });
    }

    private static IResult Token(TokenRequestDto dto)
    {
        var validation = DtoValidation.Validate(dto);
        if (validation != null) return validation;

        var devSecret = Environment.GetEnvironmentVariable("DEV_AUTH_SECRET");
        if (string.IsNullOrWhiteSpace(devSecret) || dto.Secret != devSecret)
        {
            return Results.Unauthorized();
        }

        var keyStr = Environment.GetEnvironmentVariable("JWT__Key");
        if (string.IsNullOrWhiteSpace(keyStr))
        {
            return Results.Problem("Missing env var: JWT__Key", statusCode: 500);
        }

        var issuer = Environment.GetEnvironmentVariable("JWT__Issuer") ?? "ProConnectNB";
        var audience = Environment.GetEnvironmentVariable("JWT__Audience") ?? "ProConnectNB";
        var expiresMinutes = long.TryParse(Environment.GetEnvironmentVariable("JWT__ExpiresMinutes"), out var mins) ? mins : 120;

        var claims = new List<Claim>
        {
            new(ClaimTypes.Email, dto.Email),
            new(ClaimTypes.Role, dto.Role)
        };

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(keyStr));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
        var token = new JwtSecurityToken(
            issuer: issuer,
            audience: audience,
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(expiresMinutes),
            signingCredentials: creds
        );

        var accessToken = new JwtSecurityTokenHandler().WriteToken(token);
        return Results.Ok(new TokenResponseDto
        {
            AccessToken = accessToken,
            TokenType = "Bearer",
            ExpiresInSeconds = expiresMinutes * 60
        });
    }
}

