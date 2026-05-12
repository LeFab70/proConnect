using backend.Dtos.Medicaments;
using backend.Infrastructure;
using backend.Services.Interfaces;
using System.Security.Claims;
using Microsoft.EntityFrameworkCore;

namespace backend.Endpoints;

public static class MedicamentsEndpoints
{
    public static void MapMedicamentsEndpoints(this WebApplication app)
    {
        var route = app.MapGroup("/api/medicaments").WithTags("Medicaments").RequireAuthorization();

        route.MapGet("/", GetAll)
            .Produces<IReadOnlyList<MedicamentResponseDto>>(StatusCodes.Status200OK)
            .WithSummary("Récupère les médicaments de l'utilisateur connecté (aîné = les siens, aidant = ceux de ses aînés actifs).");
        route.MapGet("/{id:long}", GetById)
            .Produces<MedicamentResponseDto>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Récupère un médicament par id");

        route.MapPost("/", Create)
            .Produces(StatusCodes.Status201Created)
            .WithSummary("Crée un médicament");

        route.MapPut("/{id:long}", Update)
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Met à jour un médicament");

        route.MapDelete("/{id:long}", Delete)
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Marque le médicament comme supprimé (is_deleted = true), soft delete");
    }

    private static async Task<IResult> GetAll(ClaimsPrincipal user, IMedicamentService svc, CancellationToken ct)
    {
        var idRaw = user.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!long.TryParse(idRaw, out var userId)) return Results.Unauthorized();
        var roles = user.FindAll(ClaimTypes.Role).Select(r => r.Value).ToArray();
        var items = await svc.GetForUser(userId, roles, ct);
        return Results.Ok(items);
    }

    private static async Task<IResult> GetById(long id, IMedicamentService svc)
    {
        var r = await svc.GetById(id);
        return r == null ? Results.NotFound() : Results.Ok(r);
    }

    private static async Task<IResult> Create(
        UpsertMedicamentRequestDto dto,
        ClaimsPrincipal user,
        IMedicamentService svc,
        AppDbContext db,
        CancellationToken ct)
    {
        var idRaw = user.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!long.TryParse(idRaw, out var userId)) return Results.Unauthorized();
        var roles = user.FindAll(ClaimTypes.Role).Select(r => r.Value.Trim().ToUpperInvariant()).ToArray();

        if (roles.Contains("AINE"))
        {
            dto.AineId = userId;
        }
        else if (!await _canAccessAine(dto.AineId, userId, db, ct))
        {
            return Results.Forbid();
        }

        var validation = DtoValidation.Validate(dto);
        if (validation != null) return validation;

        var created = await svc.Create(dto);
        return Results.Created($"/api/medicaments/{created.Id}", created);
    }

    private static async Task<IResult> Update(
        long id,
        UpsertMedicamentRequestDto dto,
        ClaimsPrincipal user,
        IMedicamentService svc,
        AppDbContext db,
        CancellationToken ct)
    {
        var idRaw = user.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!long.TryParse(idRaw, out var userId)) return Results.Unauthorized();
        var roles = user.FindAll(ClaimTypes.Role).Select(r => r.Value.Trim().ToUpperInvariant()).ToArray();

        var validation = DtoValidation.Validate(dto);
        if (validation != null) return validation;

        var aineId = await db.Medicaments.AsNoTracking()
            .Where(m => m.Id == id && !m.IsDeleted)
            .Select(m => (long?)m.AineId)
            .FirstOrDefaultAsync(ct);
        if (aineId == null) return Results.NotFound();

        if (roles.Contains("AINE"))
        {
            if (aineId.Value != userId) return Results.Forbid();
        }
        else if (!await _canAccessAine(aineId.Value, userId, db, ct))
        {
            return Results.Forbid();
        }

        var ok = await svc.Update(id, dto);
        return ok ? Results.NoContent() : Results.NotFound();
    }

    private static async Task<IResult> Delete(
        long id,
        ClaimsPrincipal user,
        IMedicamentService svc,
        AppDbContext db,
        CancellationToken ct)
    {
        var idRaw = user.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!long.TryParse(idRaw, out var userId)) return Results.Unauthorized();
        var roles = user.FindAll(ClaimTypes.Role).Select(r => r.Value.Trim().ToUpperInvariant()).ToArray();

        var aineId = await db.Medicaments.AsNoTracking()
            .Where(m => m.Id == id && !m.IsDeleted)
            .Select(m => (long?)m.AineId)
            .FirstOrDefaultAsync(ct);
        if (aineId == null) return Results.NotFound();

        if (roles.Contains("AINE"))
        {
            if (aineId.Value != userId) return Results.Forbid();
        }
        else if (!await _canAccessAine(aineId.Value, userId, db, ct))
        {
            return Results.Forbid();
        }

        var ok = await svc.Delete(id);
        return ok ? Results.NoContent() : Results.NotFound();
    }

    private static Task<bool> _canAccessAine(long aineId, long userId, AppDbContext db, CancellationToken ct)
        => db.PartagesSuivi.AsNoTracking()
            .AnyAsync(p => p.ProcheAidantId == userId && p.AineId == aineId && p.Statut == "actif", ct);
}
