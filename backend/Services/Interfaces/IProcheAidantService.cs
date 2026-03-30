using backend.Dtos.Common;
using backend.Dtos.ProchesAidants;

namespace backend.Services.Interfaces;

public interface IProcheAidantService
{
    Task<ProcheAidantResponseDto?> GetById(long id);
    Task<IdResponseDto> Create(UpsertProcheAidantRequestDto dto);
    Task<bool> Update(long id, UpsertProcheAidantRequestDto dto);
    Task<bool> Delete(long id);
}

