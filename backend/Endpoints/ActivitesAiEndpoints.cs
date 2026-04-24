using backend.Dtos.Activites;
using backend.Infrastructure;
using backend.Services.Interfaces;

namespace backend.Endpoints;

public static class ActivitesAiEndpoints
{
    public static void MapActivitesAiEndpoints(this WebApplication app)
    {
        var route = app.MapGroup("/api/activites").WithTags("Activites").RequireAuthorization();

        route.MapPost("/suggestions", Suggest)
            .Produces<IReadOnlyList<ActivitySuggestionDto>>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status400BadRequest)
            .WithSummary("Suggère des activités communautaires via IA (mock par défaut)");
    }

    private static async Task<IResult> Suggest(GetSuggestedActivitiesRequestDto dto, ICommunityActivitiesAiService ai, CancellationToken ct)
    {
        var validation = DtoValidation.Validate(dto);
        if (validation != null) return validation;

        var suggestions = await ai.Suggest(dto, ct);
        return Results.Ok(suggestions);
    }
}

