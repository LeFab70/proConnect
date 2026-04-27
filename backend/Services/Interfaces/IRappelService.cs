using backend.Dtos.Common;
using backend.Dtos.Rappels;

namespace backend.Services.Interfaces;

// Interface pour le service de gestion des rappels
public interface IRappelService
{
    Task<IReadOnlyList<RappelResponseDto>> GetAll();
    Task<RappelResponseDto?> GetById(long id);
    Task<string?> GetLinkErrorAsync(UpsertRappelRequestDto dto, CancellationToken ct = default);
    Task<IdResponseDto> Create(UpsertRappelRequestDto dto);
    Task<bool> Update(long id, UpsertRappelRequestDto dto);
    Task<bool> Delete(long id);
}