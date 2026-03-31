using backend.Dtos.Common;
using backend.Dtos.Partages;

namespace backend.Services.Interfaces;

public interface IPartageSuiviService
{
    Task<IReadOnlyList<PartageSuiviResponseDto>> GetAll();
    Task<PartageSuiviResponseDto?> GetById(long id);
    Task<IdResponseDto> Create(UpsertPartageSuiviRequestDto dto);
    Task<bool> Update(long id, UpsertPartageSuiviRequestDto dto);
    Task<bool> Delete(long id);
}

