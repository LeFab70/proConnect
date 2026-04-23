using backend.Dtos.Activites;

namespace backend.Services.Interfaces;

public interface ICommunityActivitiesAiService
{
    Task<IReadOnlyList<ActivitySuggestionDto>> Suggest(GetSuggestedActivitiesRequestDto dto, CancellationToken ct = default);
}

