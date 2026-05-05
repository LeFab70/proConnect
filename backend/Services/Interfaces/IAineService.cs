using backend.Dtos.Aines;
using backend.Dtos.Common;

namespace backend.Services.Interfaces;

// Interface pour les opérations CRUD sur les Aines
public interface IAineService
{
    Task<IReadOnlyList<AineResponseDto>> GetAll();
    Task<AineResponseDto?> GetById(long id);
    Task<IReadOnlyList<AineResponseDto>> GetForProcheAidant(long procheAidantId);
    Task<IdResponseDto> Create(UpsertAineRequestDto dto);
    Task<bool> Update(long id, UpsertAineRequestDto dto);
    Task<bool> Delete(long id);
}