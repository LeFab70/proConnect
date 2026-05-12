using backend.Dtos.Rappels;
using backend.Infrastructure;
using backend.Services.Interfaces;
using System.Security.Claims;
using Microsoft.EntityFrameworkCore;

namespace backend.Endpoints;

public static class RappelsEndpoints
{
    public static void MapRappelsEndpoints(this WebApplication app)
    {
        var route = app.MapGroup("/api/rappels").WithTags("Rappels").RequireAuthorization();

        route.MapGet("/", GetAll)
            .Produces<IReadOnlyList<RappelResponseDto>>(StatusCodes.Status200OK)
            .WithSummary("Récupère tous les rappels");
        route.MapGet("/{id:long}", GetById)
            .Produces<RappelResponseDto>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Récupère un rappel par id");

        route.MapPost("/", Create)
            .Produces(StatusCodes.Status201Created)
            .Produces(StatusCodes.Status400BadRequest)
            .WithSummary("Crée un rappel. Type: Medicament (medicament_id) ou RendezVousMedical (rendez_vous_medical_id). MinutesAvantRappel = décalage avant la prise ou le RDV.");

        route.MapPut("/{id:long}", Update)
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Met à jour un rappel");

        route.MapDelete("/{id:long}", Delete)
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Supprime un rappel");
    }

    private static async Task<IResult> GetAll(ClaimsPrincipal user, IRappelService svc, CancellationToken ct)
    {
        var idRaw = user.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!long.TryParse(idRaw, out var userId)) return Results.Unauthorized();
        var roles = user.FindAll(ClaimTypes.Role).Select(r => r.Value).ToArray();
        var items = await svc.GetForUser(userId, roles, ct);
        return Results.Ok(items);
    }

    private static async Task<IResult> GetById(long id, IRappelService svc)
    {
        var r = await svc.GetById(id);
        return r == null ? Results.NotFound() : Results.Ok(r);
    }

    private static async Task<IResult> Create(
        UpsertRappelRequestDto dto,
        ClaimsPrincipal user,
        IRappelService svc,
        AppDbContext db,
        CancellationToken ct)
    {
        var validation = DtoValidation.Validate(dto);
        if (validation != null) return validation;

        var err = RappelRequestValidation.GetError(dto);
        if (err != null) return Results.BadRequest(new { message = err });

        var linkErr = await svc.GetLinkErrorAsync(dto, ct);
        if (linkErr != null) return Results.BadRequest(new { message = linkErr });

        var idRaw = user.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!long.TryParse(idRaw, out var userId)) return Results.Unauthorized();
        var roles = user.FindAll(ClaimTypes.Role).Select(r => r.Value.Trim().ToUpperInvariant()).ToArray();

        if (!await _canAccessRappelEntity(dto.MedicamentId, dto.RendezVousMedicalId, userId, roles, db, ct))
            return Results.Forbid();

        var created = await svc.Create(dto);
        return Results.Created($"/api/rappels/{created.Id}", created);
    }

    private static async Task<IResult> Update(
        long id,
        UpsertRappelRequestDto dto,
        ClaimsPrincipal user,
        IRappelService svc,
        AppDbContext db,
        CancellationToken ct)
    {
        var validation = DtoValidation.Validate(dto);
        if (validation != null) return validation;

        var err = RappelRequestValidation.GetError(dto);
        if (err != null) return Results.BadRequest(new { message = err });

        var linkErr = await svc.GetLinkErrorAsync(dto, ct);
        if (linkErr != null) return Results.BadRequest(new { message = linkErr });

        var idRaw = user.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!long.TryParse(idRaw, out var userId)) return Results.Unauthorized();
        var roles = user.FindAll(ClaimTypes.Role).Select(r => r.Value.Trim().ToUpperInvariant()).ToArray();

        if (!await _canAccessRappelEntity(dto.MedicamentId, dto.RendezVousMedicalId, userId, roles, db, ct))
            return Results.Forbid();

        var ok = await svc.Update(id, dto);
        return ok ? Results.NoContent() : Results.NotFound();
    }

    private static async Task<IResult> Delete(
        long id,
        ClaimsPrincipal user,
        IRappelService svc,
        AppDbContext db,
        CancellationToken ct)
    {
        var idRaw = user.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!long.TryParse(idRaw, out var userId)) return Results.Unauthorized();
        var roles = user.FindAll(ClaimTypes.Role).Select(r => r.Value.Trim().ToUpperInvariant()).ToArray();

        var rappel = await db.Rappels.AsNoTracking().FirstOrDefaultAsync(r => r.Id == id, ct);
        if (rappel == null) return Results.NotFound();

        if (!await _canAccessRappelEntity(rappel.MedicamentId, rappel.RendezVousMedicalId, userId, roles, db, ct))
            return Results.Forbid();

        var ok = await svc.Delete(id);
        return ok ? Results.NoContent() : Results.NotFound();
    }

    private static async Task<bool> _canAccessRappelEntity(
        long? medicamentId,
        long? rendezVousMedicalId,
        long userId,
        string[] roles,
        AppDbContext db,
        CancellationToken ct)
    {
        long? aineId = null;

        if (medicamentId.HasValue)
            aineId = await db.Medicaments.AsNoTracking()
                .Where(m => m.Id == medicamentId.Value && !m.IsDeleted)
                .Select(m => (long?)m.AineId)
                .FirstOrDefaultAsync(ct);
        else if (rendezVousMedicalId.HasValue)
            aineId = await db.RendezVousMedicaux.AsNoTracking()
                .Where(r => r.Id == rendezVousMedicalId.Value)
                .Select(r => (long?)r.AineId)
                .FirstOrDefaultAsync(ct);

        if (!aineId.HasValue) return true;

        var roleSet = new HashSet<string>(roles);
        if (roleSet.Contains("AINE")) return aineId.Value == userId;

        return await db.PartagesSuivi.AsNoTracking()
            .AnyAsync(p => p.ProcheAidantId == userId && p.AineId == aineId.Value && p.Statut == "actif", ct);
    }
}
