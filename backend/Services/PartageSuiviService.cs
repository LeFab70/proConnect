using backend.Dtos.Common;
using backend.Dtos.Partages;
using backend.Infrastructure;
using backend.Models;
using backend.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace backend.Services;

// Service pour gérer les partages de suivi entre aînés et proches aidants
public class PartageSuiviService(AppDbContext db) : IPartageSuiviService
{
    private readonly AppDbContext _db = db; // Injection du contexte de base de données

    public async Task<IReadOnlyList<PartageSuiviResponseDto>> GetAll() // Récupère tous les partages de suivi
    {
        return await _db.PartagesSuivi
            .AsNoTracking()
            .OrderBy(p => p.Id)
            .Select(p => new PartageSuiviResponseDto
            {
                Id = p.Id,
                Autorisation = p.Autorisation,
                AineId = p.AineId,
                ProcheAidantId = p.ProcheAidantId
            })
            .ToListAsync();
    }

    public async Task<PartageSuiviResponseDto?> GetById(long id) // Récupère un partage de suivi par son ID
    {
        return await _db.PartagesSuivi
            .AsNoTracking()
            .Where(p => p.Id == id)
            .Select(p => new PartageSuiviResponseDto
            {
                Id = p.Id,
                Autorisation = p.Autorisation,
                AineId = p.AineId,
                ProcheAidantId = p.ProcheAidantId
            })
            .FirstOrDefaultAsync();
    }

    public async Task<IdResponseDto> Create(UpsertPartageSuiviRequestDto dto) // Crée un nouveau partage de suivi
    {
        var entity = new PartageSuivi
        {
            Autorisation = dto.Autorisation,
            AineId = dto.AineId,
            ProcheAidantId = dto.ProcheAidantId
        };
        _db.PartagesSuivi.Add(entity);
        await _db.SaveChangesAsync();
        return new IdResponseDto { Id = entity.Id };
    }

    public async Task<bool> Update(long id, UpsertPartageSuiviRequestDto dto) // Met à jour un partage de suivi existant
    {
        var entity = await _db.PartagesSuivi.FirstOrDefaultAsync(p => p.Id == id);
        if (entity == null) return false;

        entity.Autorisation = dto.Autorisation;
        entity.AineId = dto.AineId;
        entity.ProcheAidantId = dto.ProcheAidantId;

        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> Delete(long id) // Supprime un partage de suivi par son ID
    {
        var entity = await _db.PartagesSuivi.FirstOrDefaultAsync(p => p.Id == id);
        if (entity == null) return false;
        _db.PartagesSuivi.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }
}