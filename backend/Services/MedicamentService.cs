using backend.Dtos.Common;
using backend.Dtos.Medicaments;
using backend.Infrastructure;
using backend.Models;
using backend.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace backend.Services;

// Service pour gérer les médicaments associés aux aînés
public class MedicamentService(AppDbContext db) : IMedicamentService
{
    private readonly AppDbContext _db = db;

    public async Task<IReadOnlyList<MedicamentResponseDto>> GetAll()
    {
        return await _db.Medicaments
            .AsNoTracking()
            .Where(m => !m.IsDeleted)
            .OrderBy(m => m.Id)
            .Select(m => new MedicamentResponseDto
            {
                Id = m.Id,
                Nom = m.Nom,
                Marque = m.Marque,
                Dosage = m.Dosage,
                Frequence = m.Frequence,
                UrlPhoto = m.UrlPhoto,
                AineId = m.AineId,
                IsActive = m.IsActive,
                IsDeleted = m.IsDeleted
            })
            .ToListAsync();
    }

    public async Task<MedicamentResponseDto?> GetById(long id)
    {
        return await _db.Medicaments
            .AsNoTracking()
            .Where(m => m.Id == id && !m.IsDeleted)
            .Select(m => new MedicamentResponseDto
            {
                Id = m.Id,
                Nom = m.Nom,
                Marque = m.Marque,
                Dosage = m.Dosage,
                Frequence = m.Frequence,
                UrlPhoto = m.UrlPhoto,
                AineId = m.AineId,
                IsActive = m.IsActive,
                IsDeleted = m.IsDeleted
            })
            .FirstOrDefaultAsync();
    }

    public async Task<IdResponseDto> Create(UpsertMedicamentRequestDto dto)
    {
        var entity = new Medicament
        {
            Nom = dto.Nom,
            Marque = dto.Marque,
            Dosage = dto.Dosage,
            Frequence = dto.Frequence,
            UrlPhoto = dto.UrlPhoto,
            AineId = dto.AineId,
            IsActive = dto.IsActive ?? true,
            IsDeleted = false
        };
        _db.Medicaments.Add(entity);
        await _db.SaveChangesAsync();
        return new IdResponseDto { Id = entity.Id };
    }

    public async Task<bool> Update(long id, UpsertMedicamentRequestDto dto)
    {
        var entity = await _db.Medicaments.FirstOrDefaultAsync(m => m.Id == id && !m.IsDeleted);
        if (entity == null) return false;

        entity.Nom = dto.Nom;
        entity.Marque = dto.Marque;
        entity.Dosage = dto.Dosage;
        entity.Frequence = dto.Frequence;
        entity.UrlPhoto = dto.UrlPhoto;
        entity.AineId = dto.AineId;
        entity.IsActive = dto.IsActive ?? true;

        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> Delete(long id)
    {
        var entity = await _db.Medicaments.FirstOrDefaultAsync(m => m.Id == id && !m.IsDeleted);
        if (entity == null) return false;
        entity.IsDeleted = true;
        await _db.SaveChangesAsync();
        return true;
    }
}
