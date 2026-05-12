using backend.Dtos.Common;
using backend.Dtos.Rappels;
using backend.Infrastructure;
using backend.Models;
using backend.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace backend.Services;

// Service pour gérer les rappels de médicaments et de rendez-vous médicaux
public class RappelService(AppDbContext db) : IRappelService
{
    private readonly AppDbContext _db = db;

    public async Task<string?> GetLinkErrorAsync(UpsertRappelRequestDto dto, CancellationToken ct = default)
    {
        var type = dto.Type.Trim();
        if (type.Equals(RappelRequestValidation.TypeMedicament, StringComparison.OrdinalIgnoreCase))
        {
            var id = dto.MedicamentId!.Value;
            var ok = await _db.Medicaments.AsNoTracking().AnyAsync(m => m.Id == id && !m.IsDeleted, ct);
            return ok ? null : "Médicament introuvable ou supprimé (is_deleted).";
        }

        if (type.Equals(RappelRequestValidation.TypeRendezVousMedical, StringComparison.OrdinalIgnoreCase))
        {
            var id = dto.RendezVousMedicalId!.Value;
            var ok = await _db.RendezVousMedicaux.AsNoTracking().AnyAsync(r => r.Id == id, ct);
            return ok ? null : "Rendez-vous médical introuvable.";
        }

        return null;
    }

    public async Task<IReadOnlyList<RappelResponseDto>> GetAll()
    {
        var rows = await _db.Rappels.AsNoTracking().OrderBy(r => r.Id).ToListAsync();
        return rows.Select(Map).ToList();
    }

    public async Task<IReadOnlyList<RappelResponseDto>> GetForUser(long userId, string[] roles, CancellationToken ct = default)
    {
        var roleSet = new HashSet<string>(roles.Select(r => r.Trim().ToUpperInvariant()));
        var isAine = roleSet.Contains("AINE");

        // Collect the aîné IDs accessible to this user.
        List<long> aineIds;
        if (isAine)
        {
            aineIds = [userId];
        }
        else
        {
            aineIds = await _db.PartagesSuivi.AsNoTracking()
                .Where(p => p.ProcheAidantId == userId && p.Statut == "actif")
                .Select(p => p.AineId)
                .Distinct()
                .ToListAsync(ct);
        }

        // Rappels liés à un médicament de ces aînés.
        var medIds = await _db.Medicaments.AsNoTracking()
            .Where(m => !m.IsDeleted && aineIds.Contains(m.AineId))
            .Select(m => m.Id)
            .ToListAsync(ct);

        // Rappels liés à un RDV de ces aînés.
        var rdvIds = await _db.RendezVousMedicaux.AsNoTracking()
            .Where(r => aineIds.Contains(r.AineId))
            .Select(r => r.Id)
            .ToListAsync(ct);

        var rows = await _db.Rappels.AsNoTracking()
            .Where(r =>
                (r.MedicamentId != null && medIds.Contains(r.MedicamentId.Value)) ||
                (r.RendezVousMedicalId != null && rdvIds.Contains(r.RendezVousMedicalId.Value)))
            .OrderBy(r => r.Id)
            .ToListAsync(ct);

        return rows.Select(Map).ToList();
    }

    public async Task<RappelResponseDto?> GetById(long id)
    {
        var r = await _db.Rappels.AsNoTracking().FirstOrDefaultAsync(x => x.Id == id);
        return r == null ? null : Map(r);
    }

    public async Task<IdResponseDto> Create(UpsertRappelRequestDto dto)
    {
        var typeCanon = NormalizeType(dto.Type);
        var entity = new Rappel
        {
            DateDebut = dto.DateDebut,
            HeureDebut = dto.HeureDebut,
            MinutesAvantRappel = dto.MinutesAvantRappel,
            Type = typeCanon,
            Actif = dto.Actif,
            MedicamentId = dto.MedicamentId,
            RendezVousMedicalId = dto.RendezVousMedicalId
        };
        _db.Rappels.Add(entity);
        await _db.SaveChangesAsync();
        return new IdResponseDto { Id = entity.Id };
    }

    public async Task<bool> Update(long id, UpsertRappelRequestDto dto)
    {
        var entity = await _db.Rappels.FirstOrDefaultAsync(r => r.Id == id);
        if (entity == null) return false;

        entity.DateDebut = dto.DateDebut;
        entity.HeureDebut = dto.HeureDebut;
        entity.MinutesAvantRappel = dto.MinutesAvantRappel;
        entity.Type = NormalizeType(dto.Type);
        entity.Actif = dto.Actif;
        entity.MedicamentId = dto.MedicamentId;
        entity.RendezVousMedicalId = dto.RendezVousMedicalId;

        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> Delete(long id)
    {
        var entity = await _db.Rappels.FirstOrDefaultAsync(r => r.Id == id);
        if (entity == null) return false;
        _db.Rappels.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }

    private static string NormalizeType(string type)
    {
        var t = type.Trim();
        if (t.Equals(RappelRequestValidation.TypeMedicament, StringComparison.OrdinalIgnoreCase))
            return RappelRequestValidation.TypeMedicament;
        if (t.Equals(RappelRequestValidation.TypeRendezVousMedical, StringComparison.OrdinalIgnoreCase))
            return RappelRequestValidation.TypeRendezVousMedical;
        return t;
    }

    private static RappelResponseDto Map(Rappel r)
    {
        var prise = RappelScheduling.DateHeurePrise(r.DateDebut, r.HeureDebut);
        var notif = RappelScheduling.DateHeureNotification(r.DateDebut, r.HeureDebut, r.MinutesAvantRappel);
        return new RappelResponseDto
        {
            Id = r.Id,
            DateDebut = r.DateDebut,
            HeureDebut = r.HeureDebut,
            MinutesAvantRappel = r.MinutesAvantRappel,
            DateHeurePrise = prise,
            DateHeureNotification = notif,
            Type = r.Type,
            Actif = r.Actif,
            MedicamentId = r.MedicamentId,
            RendezVousMedicalId = r.RendezVousMedicalId
        };
    }
}
