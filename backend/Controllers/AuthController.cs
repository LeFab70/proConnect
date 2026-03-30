using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using backend.Dtos.Auth;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;

namespace backend.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    [HttpPost("token")]
    public IActionResult Token([FromBody] TokenRequestDto dto)
    {
        var devSecret = Environment.GetEnvironmentVariable("DEV_AUTH_SECRET");
        if (string.IsNullOrWhiteSpace(devSecret) || dto.Secret != devSecret)
        {
            return Unauthorized("Invalid DEV_AUTH_SECRET");
        }

        var jwtKey = Environment.GetEnvironmentVariable("JWT__Key");
        if (string.IsNullOrWhiteSpace(jwtKey))
        {
            return StatusCode(500, "Missing env var: JWT__Key");
        }

        var issuer = Environment.GetEnvironmentVariable("JWT__Issuer") ?? "ProConnectNB";
        var audience = Environment.GetEnvironmentVariable("JWT__Audience") ?? "ProConnectNB";
        var expiresMinutes = long.TryParse(Environment.GetEnvironmentVariable("JWT__ExpiresMinutes"), out var mins) ? mins : 120;

        var claims = new List<Claim>
        {
            new(ClaimTypes.Email, dto.Email),
            new(ClaimTypes.Role, dto.Role)
        };

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

        return Ok(new TokenResponseDto
        {
            AccessToken = accessToken,
            TokenType = "Bearer",
            ExpiresInSeconds = expiresMinutes * 60
        });
    }
}

