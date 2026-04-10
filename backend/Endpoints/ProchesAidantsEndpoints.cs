using backend.Dtos.ProchesAidants;
using backend.Infrastructure;
using backend.Services.Interfaces;

namespace backend.Endpoints;

// Classe pour les endpoints liés aux proches aidants
public static class ProchesAidantsEndpoints
{
    public static void MapProchesAidantsEndpoints(this WebApplication app) // Methode d'extension pour ajouter les endpoints à l'application
    {
        var route = app.MapGroup("/api/proches-aidants").WithTags("ProchesAidants").RequireAuthorization();

        route.MapGet("/", GetAll)
            .Produces<IReadOnlyList<ProcheAidantResponseDto>>(StatusCodes.Status200OK)
            .WithSummary("Récupère tous les proches aidants");
        route.MapGet("/{id:long}", GetById)
            .Produces<ProcheAidantResponseDto>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Récupère un proche aidant par id");

        route.MapPost("/", Create)
            .RequireAuthorization("AdminOnly")
            .Produces(StatusCodes.Status201Created)
            .WithSummary("Crée un proche aidant (Admin)");

        route.MapPut("/{id:long}", Update)
            .RequireAuthorization("AdminOnly")
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Met à jour un proche aidant (Admin)");

        route.MapDelete("/{id:long}", Delete)
            .RequireAuthorization("AdminOnly")
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Supprime un proche aidant (Admin)");
    }

    private static async Task<IResult> GetAll(IProcheAidantService svc) // Endpoint pour récupérer tous les proches aidants
    {
        var items = await svc.GetAll();
        return Results.Ok(items);
    }

    private static async Task<IResult> GetById(long id, IProcheAidantService svc) // Endpoint pour récupérer un proche aidant par id
    {
        var r = await svc.GetById(id);
        return r == null ? Results.NotFound() : Results.Ok(r);
    }

    private static async Task<IResult> Create(UpsertProcheAidantRequestDto dto, IProcheAidantService svc) // Endpoint pour créer un proche aidant
    {
        var validation = DtoValidation.Validate(dto);
        if (validation != null) return validation;

        var created = await svc.Create(dto);
        return Results.Created($"/api/proches-aidants/{created.Id}", created);
    }

    private static async Task<IResult> Update(long id, UpsertProcheAidantRequestDto dto, IProcheAidantService svc) // Endpoint pour mettre à jour un proche aidant
    {
        var validation = DtoValidation.Validate(dto);
        if (validation != null) return validation;

        var ok = await svc.Update(id, dto);
        return ok ? Results.NoContent() : Results.NotFound();
    }

    private static async Task<IResult> Delete(long id, IProcheAidantService svc) // Endpoint pour supprimer un proche aidant
    {
        var ok = await svc.Delete(id);
        return ok ? Results.NoContent() : Results.NotFound();
    }
}