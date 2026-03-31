using backend.Dtos.Common;
using backend.Dtos.RendezVous;

namespace backend.Services.Interfaces;

public interface IRendezVousMedicalService
{
    Task<IReadOnlyList<RendezVousMedicalResponseDto>> GetAll();
    Task<RendezVousMedicalResponseDto?> GetById(long id);
    Task<IdResponseDto> Create(UpsertRendezVousMedicalRequestDto dto);
    Task<bool> Update(long id, UpsertRendezVousMedicalRequestDto dto);
    Task<bool> Delete(long id);
}

