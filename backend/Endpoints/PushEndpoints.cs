using System.Security.Claims;
using backend.Dtos.Push;
using backend.Infrastructure;
using backend.Models;
using Microsoft.EntityFrameworkCore;

namespace backend.Endpoints;

public static class PushEndpoints
{
    public static void MapPushEndpoints(this WebApplication app)
    {
        var route = app.MapGroup("/api/push").WithTags("Push").RequireAuthorization();

        route.MapPost("/token", UpsertToken)
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status400BadRequest)
            .WithSummary("Enregistre (upsert) le token FCM du device pour l'utilisateur connecté.");

        route.MapDelete("/token", DisableToken)
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status400BadRequest)
            .WithSummary("Désactive un token FCM (logout / uninstall).");
    }

    private static async Task<IResult> UpsertToken(
        UpsertDeviceTokenRequestDto dto,
        ClaimsPrincipal user,
        AppDbContext db,
        CancellationToken ct)
    {
        var validation = DtoValidation.Validate(dto);
        if (validation != null) return validation;

        var idRaw = user.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!long.TryParse(idRaw, out var userId)) return Results.Unauthorized();

        var token = dto.Token.Trim();
        var platform = dto.Platform?.Trim().ToLowerInvariant();

        var existing = await db.DeviceTokens.FirstOrDefaultAsync(t => t.UserId == userId && t.Token == token, ct);
        if (existing == null)
        {
            db.DeviceTokens.Add(new DeviceToken
            {
                UserId = userId,
                Token = token,
                Platform = platform,
                IsActive = true,
                CreatedAtUtc = DateTime.UtcNow,
                LastSeenAtUtc = DateTime.UtcNow
            });
        }
        else
        {
            existing.Platform = platform ?? existing.Platform;
            existing.IsActive = true;
            existing.LastSeenAtUtc = DateTime.UtcNow;
        }

        await db.SaveChangesAsync(ct);
        return Results.NoContent();
    }

    private static async Task<IResult> DisableToken(
        UpsertDeviceTokenRequestDto dto,
        ClaimsPrincipal user,
        AppDbContext db,
        CancellationToken ct)
    {
        var validation = DtoValidation.Validate(dto);
        if (validation != null) return validation;

        var idRaw = user.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!long.TryParse(idRaw, out var userId)) return Results.Unauthorized();

        var token = dto.Token.Trim();
        var existing = await db.DeviceTokens.FirstOrDefaultAsync(t => t.UserId == userId && t.Token == token, ct);
        if (existing != null)
        {
            existing.IsActive = false;
            existing.LastSeenAtUtc = DateTime.UtcNow;
            await db.SaveChangesAsync(ct);
        }
        return Results.NoContent();
    }
}

