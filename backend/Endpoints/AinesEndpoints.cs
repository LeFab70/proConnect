using backend.Dtos.Aines;
using backend.Infrastructure;
using backend.Services.Interfaces;

namespace backend.Endpoints;

// Classe pour gerer les endpoints liés aux aînés
public static class AinesEndpoints
{
    public static void MapAinesEndpoints(this WebApplication app) // Methode d'extension pour ajouter les endpoints à l'application
    {
        var route = app.MapGroup("/api/aines").WithTags("Aines").RequireAuthorization();

        route.MapGet("/", GetAll)
            .Produces<IReadOnlyList<AineResponseDto>>(StatusCodes.Status200OK)
            .WithSummary("Récupère tous les aînés");
        route.MapGet("/{id:long}", GetById)
            .Produces<AineResponseDto>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Récupère un aîné par id");

        route.MapPost("/", Create)
            .RequireAuthorization("AdminOnly")
            .Produces(StatusCodes.Status201Created)
            .WithSummary("Crée un aîné (Admin)");

        route.MapPut("/{id:long}", Update)
            .RequireAuthorization("AdminOnly")
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Met à jour un aîné (Admin)");

        route.MapDelete("/{id:long}", Delete)
            .RequireAuthorization("AdminOnly")
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Supprime un aîné (Admin)");
    }

    private static async Task<IResult> GetAll(IAineService svc) // Endpoint pour récupérer tous les aînés
    {
        var items = await svc.GetAll();
        return Results.Ok(items);
    }

    private static async Task<IResult> GetById(long id, IAineService svc) // Endpoint pour récupérer un aîné par id
    {
        var r = await svc.GetById(id);
        return r == null ? Results.NotFound() : Results.Ok(r);
    }

    private static async Task<IResult> Create(UpsertAineRequestDto dto, IAineService svc) // Endpoint pour créer un aîné
    {
        var validation = DtoValidation.Validate(dto);
        if (validation != null) return validation;

        var created = await svc.Create(dto);
        return Results.Created($"/api/aines/{created.Id}", created);
    }

    private static async Task<IResult> Update(long id, UpsertAineRequestDto dto, IAineService svc) // Endpoint pour mettre à jour un aîné
    {
        var validation = DtoValidation.Validate(dto);
        if (validation != null) return validation;

        var ok = await svc.Update(id, dto);
        return ok ? Results.NoContent() : Results.NotFound();
    }

    private static async Task<IResult> Delete(long id, IAineService svc) // Endpoint pour supprimer un aîné
    {
        var ok = await svc.Delete(id);
        return ok ? Results.NoContent() : Results.NotFound();
    }
}