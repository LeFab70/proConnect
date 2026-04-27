using backend.Dtos.Partages;
using backend.Infrastructure;
using backend.Services.Interfaces;

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
            .RequireAuthorization("AdminOnly")
            .Produces(StatusCodes.Status201Created)
            .WithSummary("Crée un partage de suivi (Admin)");

        route.MapPut("/{id:long}", Update)
            .RequireAuthorization("AdminOnly")
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Met à jour un partage de suivi (Admin)");

        route.MapDelete("/{id:long}", Delete)
            .RequireAuthorization("AdminOnly")
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Supprime un partage de suivi (Admin)");
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

        var created = await svc.Create(dto);
        return Results.Created($"/api/partages-suivi/{created.Id}", created);
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