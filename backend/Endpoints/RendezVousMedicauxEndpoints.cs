using backend.Dtos.RendezVous;
using backend.Infrastructure;
using backend.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace backend.Endpoints;

public static class RendezVousMedicauxEndpoints
{
    public static void MapRendezVousMedicauxEndpoints(this WebApplication app)
    {
        // Canonical route used by the Flutter frontend.
        var route = app.MapGroup("/api/rendez-vous-medicaux").WithTags("RendezVousMedicaux").RequireAuthorization();
        // Alias route (English) to match some frontend wording.
        var appointments = app.MapGroup("/api/appointments").WithTags("RendezVousMedicaux").RequireAuthorization();

        route.MapGet("/", GetMine)
            .Produces<IReadOnlyList<RendezVousMedicalResponseDto>>(StatusCodes.Status200OK)
            .WithSummary("Récupère les rendez-vous médicaux visibles pour l'utilisateur connecté");
        route.MapGet("/{id:long}", GetById)
            .Produces<RendezVousMedicalResponseDto>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Récupère un rendez-vous médical par id");

        route.MapPost("/", Create)
            .Produces(StatusCodes.Status201Created)
            .Produces(StatusCodes.Status400BadRequest)
            .WithSummary("Crée un rendez-vous médical");

        route.MapPut("/{id:long}", Update)
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Met à jour un rendez-vous médical");

        route.MapDelete("/{id:long}", Delete)
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Supprime un rendez-vous médical");

        // Mirror endpoints on /api/appointments
        appointments.MapGet("/", GetMine)
            .Produces<IReadOnlyList<RendezVousMedicalResponseDto>>(StatusCodes.Status200OK);
        appointments.MapGet("/{id:long}", GetById)
            .Produces<RendezVousMedicalResponseDto>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status404NotFound);
        appointments.MapPost("/", Create)
            .Produces(StatusCodes.Status201Created)
            .Produces(StatusCodes.Status400BadRequest);
        appointments.MapPut("/{id:long}", Update)
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status404NotFound);
        appointments.MapDelete("/{id:long}", Delete)
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status404NotFound);
    }

    private static async Task<IResult> GetMine(ClaimsPrincipal user, IRendezVousMedicalService svc, CancellationToken ct)
    {
        var idRaw = user.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!long.TryParse(idRaw, out var userId)) return Results.Unauthorized();
        var roles = user.FindAll(ClaimTypes.Role).Select(r => r.Value).ToArray();

        var items = await svc.GetForUser(userId, roles, ct);
        return Results.Ok(items);
    }

    private static async Task<IResult> GetById(long id, IRendezVousMedicalService svc)
    {
        var r = await svc.GetById(id);
        return r == null ? Results.NotFound() : Results.Ok(r);
    }

    private static async Task<IResult> Create(
        UpsertRendezVousMedicalRequestDto dto,
        ClaimsPrincipal user,
        IRendezVousMedicalService svc,
        CancellationToken ct)
    {
        var validation = DtoValidation.Validate(dto);
        if (validation != null) return validation;

        var idRaw = user.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!long.TryParse(idRaw, out var userId)) return Results.Unauthorized();
        var roles = user.FindAll(ClaimTypes.Role).Select(r => r.Value).ToArray();

        try
        {
            var created = await svc.Create(dto, userId, roles, ct);
            return Results.Created($"/api/rendez-vous-medicaux/{created.Id}", created);
        }
        catch (InvalidOperationException ex)
        {
            return Results.BadRequest(new { message = ex.Message });
        }
        catch (DbUpdateException ex)
        {
            // FK / contraintes / Npgsql : éviter un 500 vide côté client.
            return Results.Json(
                new
                {
                    message = "Erreur lors de l'enregistrement du rendez-vous.",
                    detail = ex.InnerException?.Message ?? ex.Message,
                },
                statusCode: StatusCodes.Status500InternalServerError);
        }
        catch (Exception ex)
        {
            return Results.Json(
                new { message = "Erreur serveur lors de la création du rendez-vous.", detail = ex.Message },
                statusCode: StatusCodes.Status500InternalServerError);
        }
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