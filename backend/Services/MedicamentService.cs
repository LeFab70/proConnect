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
    private readonly AppDbContext _db = db; // Injection du contexte de base de données

    public async Task<IReadOnlyList<MedicamentResponseDto>> GetAll() // Récupère tous les médicaments
    {
        return await _db.Medicaments
            .AsNoTracking()
            .OrderBy(m => m.Id)
            .Select(m => new MedicamentResponseDto
            {
                Id = m.Id,
                Nom = m.Nom,
                Marque = m.Marque,
                Dosage = m.Dosage,
                Frequence = m.Frequence,
                AineId = m.AineId
            })
            .ToListAsync();
    }

    public async Task<MedicamentResponseDto?> GetById(long id) // Récupère un médicament par son ID
    {
        return await _db.Medicaments
            .AsNoTracking()
            .Where(m => m.Id == id)
            .Select(m => new MedicamentResponseDto
            {
                Id = m.Id,
                Nom = m.Nom,
                Marque = m.Marque,
                Dosage = m.Dosage,
                Frequence = m.Frequence,
                AineId = m.AineId
            })
            .FirstOrDefaultAsync();
    }

    public async Task<IdResponseDto> Create(UpsertMedicamentRequestDto dto) // Crée un nouveau médicament
    {
        var entity = new Medicament
        {
            Nom = dto.Nom,
            Marque = dto.Marque,
            Dosage = dto.Dosage,
            Frequence = dto.Frequence,
            AineId = dto.AineId
        };
        _db.Medicaments.Add(entity);
        await _db.SaveChangesAsync();
        return new IdResponseDto { Id = entity.Id };
    }

    public async Task<bool> Update(long id, UpsertMedicamentRequestDto dto) // Met à jour un médicament existant
    {
        var entity = await _db.Medicaments.FirstOrDefaultAsync(m => m.Id == id);
        if (entity == null) return false;

        entity.Nom = dto.Nom;
        entity.Marque = dto.Marque;
        entity.Dosage = dto.Dosage;
        entity.Frequence = dto.Frequence;
        entity.AineId = dto.AineId;

        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> Delete(long id) // Supprime un médicament par son ID
    {
        var entity = await _db.Medicaments.FirstOrDefaultAsync(m => m.Id == id);
        if (entity == null) return false;
        _db.Medicaments.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }
}