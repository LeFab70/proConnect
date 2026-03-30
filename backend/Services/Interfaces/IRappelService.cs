using backend.Dtos.Common;
using backend.Dtos.Rappels;

namespace backend.Services.Interfaces;

public interface IRappelService
{
    Task<RappelResponseDto?> GetById(long id);
    Task<IdResponseDto> Create(UpsertRappelRequestDto dto);
    Task<bool> Update(long id, UpsertRappelRequestDto dto);
    Task<bool> Delete(long id);
}

