using backend.Dtos.Common;
using backend.Dtos.Medicaments;
using backend.Infrastructure;
using backend.Models;
using backend.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace backend.Services;

public class MedicamentService(AppDbContext db) : IMedicamentService
{
    private readonly AppDbContext _db = db;

    public async Task<IReadOnlyList<MedicamentResponseDto>> GetAll()
    {
        return await _db.Medicaments
            .AsNoTracking()
            .OrderBy(m => m.Id)
            .Select(m => new MedicamentResponseDto
            {
                Id = m.Id,
                Nom = m.Nom,
                Dosage = m.Dosage,
                Frequence = m.Frequence,
                AineId = m.AineId
            })
            .ToListAsync();
    }

    public async Task<MedicamentResponseDto?> GetById(long id)
    {
        return await _db.Medicaments
            .AsNoTracking()
            .Where(m => m.Id == id)
            .Select(m => new MedicamentResponseDto
            {
                Id = m.Id,
                Nom = m.Nom,
                Dosage = m.Dosage,
                Frequence = m.Frequence,
                AineId = m.AineId
            })
            .FirstOrDefaultAsync();
    }

    public async Task<IdResponseDto> Create(UpsertMedicamentRequestDto dto)
    {
        var entity = new Medicament
        {
            Nom = dto.Nom,
            Dosage = dto.Dosage,
            Frequence = dto.Frequence,
            AineId = dto.AineId
        };
        _db.Medicaments.Add(entity);
        await _db.SaveChangesAsync();
        return new IdResponseDto { Id = entity.Id };
    }

    public async Task<bool> Update(long id, UpsertMedicamentRequestDto dto)
    {
        var entity = await _db.Medicaments.FirstOrDefaultAsync(m => m.Id == id);
        if (entity == null) return false;

        entity.Nom = dto.Nom;
        entity.Dosage = dto.Dosage;
        entity.Frequence = dto.Frequence;
        entity.AineId = dto.AineId;

        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> Delete(long id)
    {
        var entity = await _db.Medicaments.FirstOrDefaultAsync(m => m.Id == id);
        if (entity == null) return false;
        _db.Medicaments.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }
}

