using backend.Dtos.Common;
using backend.Dtos.Partages;

namespace backend.Services.Interfaces;

// Interface pour le service de gestion des PartageSuivi
public interface IPartageSuiviService
{
    Task<IReadOnlyList<PartageSuiviResponseDto>> GetAll();
    Task<IReadOnlyList<PartageSuiviResponseDto>> GetForUser(long userId, string userEmail, string[] roles, CancellationToken ct = default);
    Task<PartageSuiviResponseDto?> GetById(long id);
    Task<IdResponseDto> Create(UpsertPartageSuiviRequestDto dto);
    Task<bool> Update(long id, UpsertPartageSuiviRequestDto dto);
    Task<bool> Delete(long id);
}