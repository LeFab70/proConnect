using backend.Dtos.Rappels;
using backend.Infrastructure;
using backend.Services.Interfaces;

namespace backend.Endpoints;

// Classe pour les endpoints de rappels
public static class RappelsEndpoints
{
    public static void MapRappelsEndpoints(this WebApplication app) // Methode d'extension pour ajouter les endpoints à l'application
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
            .RequireAuthorization("AdminOnly")
            .Produces(StatusCodes.Status201Created)
            .WithSummary("Crée un rappel (Admin)");

        route.MapPut("/{id:long}", Update)
            .RequireAuthorization("AdminOnly")
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Met à jour un rappel (Admin)");

        route.MapDelete("/{id:long}", Delete)
            .RequireAuthorization("AdminOnly")
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Supprime un rappel (Admin)");
    }

    private static async Task<IResult> GetAll(IRappelService svc) // Injection du service pour récupérer les rappels
    {
        var items = await svc.GetAll();
        return Results.Ok(items);
    }

    private static async Task<IResult> GetById(long id, IRappelService svc) // Injection du service pour récupérer un rappel par id
    {
        var r = await svc.GetById(id);
        return r == null ? Results.NotFound() : Results.Ok(r);
    }

    private static async Task<IResult> Create(UpsertRappelRequestDto dto, IRappelService svc) // Injection du service pour créer un rappel
    {
        var validation = DtoValidation.Validate(dto);
        if (validation != null) return validation;

        var created = await svc.Create(dto);
        return Results.Created($"/api/rappels/{created.Id}", created);
    }

    private static async Task<IResult> Update(long id, UpsertRappelRequestDto dto, IRappelService svc) // Injection du service pour mettre à jour un rappel
    {
        var validation = DtoValidation.Validate(dto);
        if (validation != null) return validation;

        var ok = await svc.Update(id, dto);
        return ok ? Results.NoContent() : Results.NotFound();
    }

    private static async Task<IResult> Delete(long id, IRappelService svc) // Injection du service pour supprimer un rappel
    {
        var ok = await svc.Delete(id);
        return ok ? Results.NoContent() : Results.NotFound();
    }
}