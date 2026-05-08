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

    private static async Task<IResult> Create(UpsertPartageSuiviRequestDto dto, IPartageSuiviService svc)
    {
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

        var entity = await db.PartagesSuivi.FirstOrDefaultAsync(p => p.Id == id, ct);
        if (entity == null) return Results.NotFound();

        // Associate to current proche aidant
        entity.ProcheAidantId = userId;
        entity.ProcheEmail = null;
        entity.Statut = "actif";
        await db.SaveChangesAsync(ct);

        return Results.NoContent();
    }

    private static async Task<IResult> Reject(
        long id,
        AppDbContext db,
        CancellationToken ct)
    {
        var entity = await db.PartagesSuivi.FirstOrDefaultAsync(p => p.Id == id, ct);
        if (entity == null) return Results.NotFound();

        entity.Statut = "refuse";
        await db.SaveChangesAsync(ct);

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