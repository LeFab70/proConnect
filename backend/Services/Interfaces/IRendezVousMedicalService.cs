using backend.Dtos.RendezVous;

namespace backend.Services.Interfaces;

// Interface pour le service de gestion des rendez-vous médicaux
public interface IRendezVousMedicalService
{
    Task<IReadOnlyList<RendezVousMedicalResponseDto>> GetAll();
    Task<IReadOnlyList<RendezVousMedicalResponseDto>> GetForUser(long userId, string[] roles, CancellationToken ct = default);
    Task<RendezVousMedicalResponseDto?> GetById(long id);
    Task<RendezVousMedicalResponseDto> Create(UpsertRendezVousMedicalRequestDto dto, long userId, string[] roles, CancellationToken ct = default);
    Task<bool> Update(long id, UpsertRendezVousMedicalRequestDto dto, long userId, string[] roles, CancellationToken ct = default);
    Task<bool> Delete(long id, long userId, string[] roles, CancellationToken ct = default);
}