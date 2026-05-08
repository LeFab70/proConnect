using backend.Dtos.Rappels;
using backend.Infrastructure;
using backend.Services.Interfaces;

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

    private static async Task<IResult> GetAll(IRappelService svc)
    {
        var items = await svc.GetAll();
        return Results.Ok(items);
    }

    private static async Task<IResult> GetById(long id, IRappelService svc)
    {
        var r = await svc.GetById(id);
        return r == null ? Results.NotFound() : Results.Ok(r);
    }

    private static async Task<IResult> Create(UpsertRappelRequestDto dto, IRappelService svc, CancellationToken ct)
    {
        var validation = DtoValidation.Validate(dto);
        if (validation != null) return validation;

        var err = RappelRequestValidation.GetError(dto);
        if (err != null) return Results.BadRequest(new { message = err });

        var linkErr = await svc.GetLinkErrorAsync(dto, ct);
        if (linkErr != null) return Results.BadRequest(new { message = linkErr });

        var created = await svc.Create(dto);
        return Results.Created($"/api/rappels/{created.Id}", created);
    }

    private static async Task<IResult> Update(long id, UpsertRappelRequestDto dto, IRappelService svc, CancellationToken ct)
    {
        var validation = DtoValidation.Validate(dto);
        if (validation != null) return validation;

        var err = RappelRequestValidation.GetError(dto);
        if (err != null) return Results.BadRequest(new { message = err });

        var linkErr = await svc.GetLinkErrorAsync(dto, ct);
        if (linkErr != null) return Results.BadRequest(new { message = linkErr });

        var ok = await svc.Update(id, dto);
        return ok ? Results.NoContent() : Results.NotFound();
    }

    private static async Task<IResult> Delete(long id, IRappelService svc)
    {
        var ok = await svc.Delete(id);
        return ok ? Results.NoContent() : Results.NotFound();
    }
}