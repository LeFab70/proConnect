using backend.Dtos.Common;
using backend.Dtos.ProchesAidants;

namespace backend.Services.Interfaces;

// Interface pour le service de gestion des proches aidants
public interface IProcheAidantService
{
    Task<IReadOnlyList<ProcheAidantResponseDto>> GetAll();
    Task<ProcheAidantResponseDto?> GetById(long id);
    Task<IdResponseDto> Create(UpsertProcheAidantRequestDto dto);
    Task<bool> Update(long id, UpsertProcheAidantRequestDto dto);
    Task<bool> Delete(long id);
}