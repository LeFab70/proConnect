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
            .WithSummary("Récupère les partages de suivi de l'utilisateur connecté");
        route.MapGet("/{id:long}", GetById)
            .Produces<PartageSuiviResponseDto>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Récupère un partage de suivi par id");

        route.MapPost("/", Create)
            .Produces(StatusCodes.Status201Created)
            .WithSummary("Crée un partage de suivi (aîné uniquement)");

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
            .WithSummary("Met à jour un partage de suivi (aîné propriétaire uniquement)");

        route.MapDelete("/{id:long}", Delete)
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Supprime un partage de suivi");
    }

    private static async Task<IResult> GetAll(
        ClaimsPrincipal user,
        IPartageSuiviService svc,
        CancellationToken ct)
    {
        var idRaw = user.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!long.TryParse(idRaw, out var userId)) return Results.Unauthorized();
        var email = user.FindFirstValue(ClaimTypes.Email) ?? "";
        var roles = user.FindAll(ClaimTypes.Role).Select(r => r.Value).ToArray();
        var items = await svc.GetForUser(userId, email, roles, ct);
        return Results.Ok(items);
    }

    private static async Task<IResult> GetById(long id, IPartageSuiviService svc)
    {
        var r = await svc.GetById(id);
        return r == null ? Results.NotFound() : Results.Ok(r);
    }

    private static async Task<IResult> Create(
        UpsertPartageSuiviRequestDto dto,
        ClaimsPrincipal user,
        IPartageSuiviService svc,
        CancellationToken ct)
    {
        var idRaw = user.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!long.TryParse(idRaw, out var userId)) return Results.Unauthorized();
        var roles = user.FindAll(ClaimTypes.Role).Select(r => r.Value.Trim().ToUpperInvariant()).ToArray();

        // Seul un aîné peut créer un partage; forcer son propre ID comme AineId.
        if (roles.Contains("AINE"))
        {
            dto.AineId = userId;
        }
        else
        {
            return Results.Forbid();
        }

        var validation = DtoValidation.Validate(dto);
        if (validation != null) return validation;

        if ((dto.ProcheAidantId == null || dto.ProcheAidantId <= 0) &&
            string.IsNullOrWhiteSpace(dto.ProcheEmail))
        {
            return Results.BadRequest(new { message = "ProcheAidantId ou ProcheEmail est requis." });
        }

        var created = await svc.Create(dto);
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
        var idRaw = user.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!long.TryParse(idRaw, out var userId)) return Results.Unauthorized();
        var roles = user.FindAll(ClaimTypes.Role).Select(r => r.Value.Trim().ToUpperInvariant()).ToArray();
        if (!roles.Contains("AIDANT")) return Results.Forbid();

        var entity = await db.PartagesSuivi.FirstOrDefaultAsync(p => p.Id == id, ct);
        if (entity == null) return Results.NotFound();

        if (!string.Equals(entity.Statut, "enAttente", StringComparison.OrdinalIgnoreCase))
        {
            return Results.Conflict(new { message = "Invitation déjà traitée." });
        }

        // Vérifier que l'invitation cible bien cet aidant
        var emailLower = user.FindFirstValue(ClaimTypes.Email)?.Trim().ToLowerInvariant();
        var emailMatch = !string.IsNullOrWhiteSpace(emailLower) &&
                         !string.IsNullOrWhiteSpace(entity.ProcheEmail) &&
                         string.Equals(entity.ProcheEmail.Trim().ToLowerInvariant(), emailLower, StringComparison.OrdinalIgnoreCase);
        var idMatch = entity.ProcheAidantId != null && entity.ProcheAidantId == userId;
        var unboundInvite = entity.ProcheAidantId == null && !string.IsNullOrWhiteSpace(entity.ProcheEmail);

        if (!(emailMatch || idMatch || unboundInvite)) return Results.Forbid();

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

    private static async Task<IResult> Update(
        long id,
        UpsertPartageSuiviRequestDto dto,
        ClaimsPrincipal user,
        IPartageSuiviService svc,
        AppDbContext db,
        CancellationToken ct)
    {
        var idRaw = user.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!long.TryParse(idRaw, out var userId)) return Results.Unauthorized();

        var validation = DtoValidation.Validate(dto);
        if (validation != null) return validation;

        // Seul l'aîné propriétaire peut modifier un partage.
        var aineId = await db.PartagesSuivi.AsNoTracking()
            .Where(p => p.Id == id)
            .Select(p => (long?)p.AineId)
            .FirstOrDefaultAsync(ct);
        if (aineId == null) return Results.NotFound();
        if (aineId.Value != userId) return Results.Forbid();

        var ok = await svc.Update(id, dto);
        return ok ? Results.NoContent() : Results.NotFound();
    }

    private static async Task<IResult> Delete(
        long id,
        ClaimsPrincipal user,
        IPartageSuiviService svc,
        AppDbContext db,
        CancellationToken ct)
    {
        var idRaw = user.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!long.TryParse(idRaw, out var userId)) return Results.Unauthorized();
        var roles = user.FindAll(ClaimTypes.Role).Select(r => r.Value.Trim().ToUpperInvariant()).ToArray();

        var entity = await db.PartagesSuivi.AsNoTracking()
            .Where(p => p.Id == id)
            .Select(p => new { p.AineId, p.ProcheAidantId })
            .FirstOrDefaultAsync(ct);
        if (entity == null) return Results.NotFound();

        // L'aîné peut supprimer ses propres partages; le proche peut quitter un partage actif.
        bool canDelete =
            (roles.Contains("AINE") && entity.AineId == userId) ||
            (roles.Contains("AIDANT") && entity.ProcheAidantId == userId);
        if (!canDelete) return Results.Forbid();

        var ok = await svc.Delete(id);
        return ok ? Results.NoContent() : Results.NotFound();
    }
}
