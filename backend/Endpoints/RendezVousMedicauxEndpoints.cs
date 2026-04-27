using backend.Dtos.RendezVous;
using backend.Infrastructure;
using backend.Services.Interfaces;

namespace backend.Endpoints;

public static class RendezVousMedicauxEndpoints
{
    public static void MapRendezVousMedicauxEndpoints(this WebApplication app)
    {
        var route = app.MapGroup("/api/rendez-vous-medicaux").WithTags("RendezVousMedicaux").RequireAuthorization();

        route.MapGet("/", GetAll)
            .Produces<IReadOnlyList<RendezVousMedicalResponseDto>>(StatusCodes.Status200OK)
            .WithSummary("Récupère tous les rendez-vous médicaux");
        route.MapGet("/{id:long}", GetById)
            .Produces<RendezVousMedicalResponseDto>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Récupère un rendez-vous médical par id");

        route.MapPost("/", Create)
            .RequireAuthorization("AdminOnly")
            .Produces(StatusCodes.Status201Created)
            .WithSummary("Crée un rendez-vous médical (Admin)");

        route.MapPut("/{id:long}", Update)
            .RequireAuthorization("AdminOnly")
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Met à jour un rendez-vous médical (Admin)");

        route.MapDelete("/{id:long}", Delete)
            .RequireAuthorization("AdminOnly")
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Supprime un rendez-vous médical (Admin)");
    }

    private static async Task<IResult> GetAll(IRendezVousMedicalService svc)
    {
        var items = await svc.GetAll();
        return Results.Ok(items);
    }

    private static async Task<IResult> GetById(long id, IRendezVousMedicalService svc)
    {
        var r = await svc.GetById(id);
        return r == null ? Results.NotFound() : Results.Ok(r);
    }

    private static async Task<IResult> Create(UpsertRendezVousMedicalRequestDto dto, IRendezVousMedicalService svc)
    {
        var validation = DtoValidation.Validate(dto);
        if (validation != null) return validation;

        var created = await svc.Create(dto);
        return Results.Created($"/api/rendez-vous-medicaux/{created.Id}", created);
    }

    private static async Task<IResult> Update(long id, UpsertRendezVousMedicalRequestDto dto, IRendezVousMedicalService svc)
    {
        var validation = DtoValidation.Validate(dto);
        if (validation != null) return validation;

        var ok = await svc.Update(id, dto);
        return ok ? Results.NoContent() : Results.NotFound();
    }

    private static async Task<IResult> Delete(long id, IRendezVousMedicalService svc)
    {
        var ok = await svc.Delete(id);
        return ok ? Results.NoContent() : Results.NotFound();
    }
}