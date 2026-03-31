using backend.Dtos.Aines;
using backend.Dtos.Common;

namespace backend.Services.Interfaces;

public interface IAineService
{
    Task<IReadOnlyList<AineResponseDto>> GetAll();
    Task<AineResponseDto?> GetById(long id);
    Task<IdResponseDto> Create(UpsertAineRequestDto dto);
    Task<bool> Update(long id, UpsertAineRequestDto dto);
    Task<bool> Delete(long id);
}

