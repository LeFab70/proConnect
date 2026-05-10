using backend.Dtos.Partages;
using backend.Infrastructure;
using backend.Services.Interfaces;
using System.Security.Claims;
using Microsoft.EntityFrameworkCore;

namespace backend.Endpoints;

public static class PartagesSuiviEndpoints
{
    public static void MapPartagesSuiviEndpoints(this WebApplication app)
    {
        var route = app.MapGroup("/api/partages-suivi").WithTags("PartagesSuivi").RequireAuthorization();

        route.MapGet("/", GetAll)
            .Produces<IReadOnlyList<PartageSuiviResponseDto>>(StatusCodes.Status200OK)
            .WithSummary("Récupère tous les partages de suivi");
        route.MapGet("/{id:long}", GetById)
            .Produces<PartageSuiviResponseDto>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Récupère un partage de suivi par id");

        route.MapPost("/", Create)
            .Produces(StatusCodes.Status201Created)
            .WithSummary("Crée un partage de suivi");

        route.MapPost("/{id:long}/accept", Accept)
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Accepte une invitation (Proche aidant)");

        route.MapPost("/{id:long}/reject", Reject)
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Refuse une invitation (Proche aidant)");

        route.MapPut("/{id:long}", Update)
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Met à jour un partage de suivi");

        route.MapDelete("/{id:long}", Delete)
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Supprime un partage de suivi");
    }

    private static async Task<IResult> GetAll(IPartageSuiviService svc)
    {
        var items = await svc.GetAll();
        return Results.Ok(items);
    }

    private static async Task<IResult> GetById(long id, IPartageSuiviService svc)
    {
        var r = await svc.GetById(id);
        return r == null ? Results.NotFound() : Results.Ok(r);
    }

    private static async Task<IResult> Create(UpsertPartageSuiviRequestDto dto, IPartageSuiviService svc, IPushNotificationService push, CancellationToken ct)
    {
        var validation = DtoValidation.Validate(dto);
        if (validation != null) return validation;

        if ((dto.ProcheAidantId == null || dto.ProcheAidantId <= 0) &&
            string.IsNullOrWhiteSpace(dto.ProcheEmail))
        {
            return Results.BadRequest(new { message = "ProcheAidantId ou ProcheEmail est requis." });
        }

        var created = await svc.Create(dto);

        // Push notify target aidant (multi-device) if we have a concrete user id.
        if (dto.ProcheAidantId != null && dto.ProcheAidantId > 0)
        {
            await push.SendToUserAsync(
                dto.ProcheAidantId.Value,
                "Nouvelle demande de partage",
                "Un aîné vous a envoyé une demande de partage de suivi.",
                data: new Dictionary<string, string>
                {
                    ["type"] = "PARTAGE_SUIVI",
                    ["partageId"] = created.Id.ToString(),
                },
                ct: ct);
        }

        return Results.Created($"/api/partages-suivi/{created.Id}", created);
    }

    private static async Task<IResult> Accept(
        long id,
        ClaimsPrincipal user,
        AppDbContext db,
        CancellationToken ct)
    {
        var idRaw = user.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!long.TryParse(idRaw, out var userId)) return Results.Unauthorized();
        var email = user.FindFirstValue(ClaimTypes.Email)?.Trim().ToLowerInvariant();
        var roles = user.FindAll(ClaimTypes.Role).Select(r => r.Value.Trim().ToUpperInvariant()).ToArray();
        if (!roles.Contains("AIDANT")) return Results.Forbid();

        var entity = await db.PartagesSuivi.FirstOrDefaultAsync(p => p.Id == id, ct);
        if (entity == null) return Results.NotFound();

        if (!string.Equals(entity.Statut, "enAttente", StringComparison.OrdinalIgnoreCase))
        {
            return Results.Conflict(new { message = "Invitation déjà traitée." });
        }

        // Invitation must target the current aidant (by id or email) when provided.
        var emailMatch = !string.IsNullOrWhiteSpace(email) &&
                         !string.IsNullOrWhiteSpace(entity.ProcheEmail) &&
                         string.Equals(entity.ProcheEmail.Trim().ToLowerInvariant(), email, StringComparison.OrdinalIgnoreCase);
        var idMatch = entity.ProcheAidantId != null && entity.ProcheAidantId == userId;
        var unboundInvite = entity.ProcheAidantId == null && !string.IsNullOrWhiteSpace(entity.ProcheEmail);

        if (!(emailMatch || idMatch || unboundInvite))
        {
            return Results.Forbid();
        }

        entity.ProcheAidantId = userId;
        entity.ProcheEmail = null;
        entity.Statut = "actif";
        try
        {
            await db.SaveChangesAsync(ct);
        }
        catch (DbUpdateException ex)
        {
            return Results.BadRequest(new { message = "Erreur base de données lors de l'acceptation.", detail = ex.InnerException?.Message ?? ex.Message });
        }

        return Results.NoContent();
    }

    private static async Task<IResult> Reject(
        long id,
        ClaimsPrincipal user,
        AppDbContext db,
        CancellationToken ct)
    {
        var roles = user.FindAll(ClaimTypes.Role).Select(r => r.Value.Trim().ToUpperInvariant()).ToArray();
        if (!roles.Contains("AIDANT")) return Results.Forbid();

        var entity = await db.PartagesSuivi.FirstOrDefaultAsync(p => p.Id == id, ct);
        if (entity == null) return Results.NotFound();

        if (!string.Equals(entity.Statut, "enAttente", StringComparison.OrdinalIgnoreCase))
        {
            return Results.Conflict(new { message = "Invitation déjà traitée." });
        }

        entity.Statut = "refuse";
        try
        {
            await db.SaveChangesAsync(ct);
        }
        catch (DbUpdateException ex)
        {
            return Results.BadRequest(new { message = "Erreur base de données lors du refus.", detail = ex.InnerException?.Message ?? ex.Message });
        }

        return Results.NoContent();
    }

    private static async Task<IResult> Update(long id, UpsertPartageSuiviRequestDto dto, IPartageSuiviService svc)
    {
        var validation = DtoValidation.Validate(dto);
        if (validation != null) return validation;

        var ok = await svc.Update(id, dto);
        return ok ? Results.NoContent() : Results.NotFound();
    }

    private static async Task<IResult> Delete(long id, IPartageSuiviService svc)
    {
        var ok = await svc.Delete(id);
        return ok ? Results.NoContent() : Results.NotFound();
    }
}