using backend.Dtos.Medicaments;
using backend.Infrastructure;
using backend.Services.Interfaces;

namespace backend.Endpoints;

public static class MedicamentsEndpoints
{
    public static void MapMedicamentsEndpoints(this WebApplication app)
    {
        var route = app.MapGroup("/api/medicaments").WithTags("Medicaments").RequireAuthorization();

        route.MapGet("/", GetAll)
            .Produces<IReadOnlyList<MedicamentResponseDto>>(StatusCodes.Status200OK)
            .WithSummary("Récupère tous les médicaments");
        route.MapGet("/{id:long}", GetById)
            .Produces<MedicamentResponseDto>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Récupère un médicament par id");

        route.MapPost("/", Create)
            .RequireAuthorization("AdminOnly")
            .Produces(StatusCodes.Status201Created)
            .WithSummary("Crée un médicament (Admin)");

        route.MapPut("/{id:long}", Update)
            .RequireAuthorization("AdminOnly")
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Met à jour un médicament (Admin)");

        route.MapDelete("/{id:long}", Delete)
            .RequireAuthorization("AdminOnly")
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Supprime un médicament (Admin)");
    }

    private static async Task<IResult> GetAll(IMedicamentService svc)
    {
        var items = await svc.GetAll();
        return Results.Ok(items);
    }

    private static async Task<IResult> GetById(long id, IMedicamentService svc)
    {
        var r = await svc.GetById(id);
        return r == null ? Results.NotFound() : Results.Ok(r);
    }

    private static async Task<IResult> Create(UpsertMedicamentRequestDto dto, IMedicamentService svc)
    {
        var validation = DtoValidation.Validate(dto);
        if (validation != null) return validation;

        var created = await svc.Create(dto);
        return Results.Created($"/api/medicaments/{created.Id}", created);
    }

    private static async Task<IResult> Update(long id, UpsertMedicamentRequestDto dto, IMedicamentService svc)
    {
        var validation = DtoValidation.Validate(dto);
        if (validation != null) return validation;

        var ok = await svc.Update(id, dto);
        return ok ? Results.NoContent() : Results.NotFound();
    }

    private static async Task<IResult> Delete(long id, IMedicamentService svc)
    {
        var ok = await svc.Delete(id);
        return ok ? Results.NoContent() : Results.NotFound();
    }
}

