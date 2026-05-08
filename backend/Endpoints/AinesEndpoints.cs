using backend.Dtos.Aines;
using backend.Infrastructure;
using backend.Services.Interfaces;
using System.Security.Claims;

namespace backend.Endpoints;

public static class AinesEndpoints
{
    public static void MapAinesEndpoints(this WebApplication app)
    {
        var route = app.MapGroup("/api/aines").WithTags("Aines").RequireAuthorization();

        route.MapGet("/mine", GetMine)
            .Produces<IReadOnlyList<AineResponseDto>>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status401Unauthorized)
            .WithSummary("Récupère les aînés rattachés au proche aidant connecté (via PartageSuivi)");

        route.MapGet("/", GetAll)
            .Produces<IReadOnlyList<AineResponseDto>>(StatusCodes.Status200OK)
            .WithSummary("Récupère tous les aînés");
        route.MapGet("/{id:long}", GetById)
            .Produces<AineResponseDto>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Récupère un aîné par id");

        route.MapPost("/", Create)
            .Produces(StatusCodes.Status201Created)
            .WithSummary("Crée un aîné");

        route.MapPut("/{id:long}", Update)
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Met à jour un aîné");

        route.MapDelete("/{id:long}", Delete)
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Supprime un aîné");
    }

    private static async Task<IResult> GetAll(IAineService svc)
    {
        var items = await svc.GetAll();
        return Results.Ok(items);
    }

    private static async Task<IResult> GetMine(ClaimsPrincipal user, IAineService svc)
    {
        var idRaw = user.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!long.TryParse(idRaw, out var userId)) return Results.Unauthorized();
        var items = await svc.GetForProcheAidant(userId);
        return Results.Ok(items);
    }

    private static async Task<IResult> GetById(long id, IAineService svc)
    {
        var r = await svc.GetById(id);
        return r == null ? Results.NotFound() : Results.Ok(r);
    }

    private static async Task<IResult> Create(UpsertAineRequestDto dto, IAineService svc)
    {
        var validation = DtoValidation.Validate(dto);
        if (validation != null) return validation;

        var created = await svc.Create(dto);
        return Results.Created($"/api/aines/{created.Id}", created);
    }

    private static async Task<IResult> Update(long id, UpsertAineRequestDto dto, IAineService svc)
    {
        var validation = DtoValidation.Validate(dto);
        if (validation != null) return validation;

        var ok = await svc.Update(id, dto);
        return ok ? Results.NoContent() : Results.NotFound();
    }

    private static async Task<IResult> Delete(long id, IAineService svc)
    {
        var ok = await svc.Delete(id);
        return ok ? Results.NoContent() : Results.NotFound();
    }
}