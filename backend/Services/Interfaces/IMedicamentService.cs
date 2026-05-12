using backend.Dtos.Common;
using backend.Dtos.Medicaments;

namespace backend.Services.Interfaces;

// Interface pour le service de gestion des médicaments
public interface IMedicamentService
{
    Task<IReadOnlyList<MedicamentResponseDto>> GetAll();
    Task<IReadOnlyList<MedicamentResponseDto>> GetForUser(long userId, string[] roles, CancellationToken ct = default);
    Task<MedicamentResponseDto?> GetById(long id);
    Task<IdResponseDto> Create(UpsertMedicamentRequestDto dto);
    Task<bool> Update(long id, UpsertMedicamentRequestDto dto);
    Task<bool> Delete(long id);
}