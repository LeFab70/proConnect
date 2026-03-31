using backend.Dtos.Common;
using backend.Dtos.Partages;
using backend.Infrastructure;
using backend.Models;
using backend.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace backend.Services;

public class PartageSuiviService(AppDbContext db) : IPartageSuiviService
{
    private readonly AppDbContext _db = db;

    public async Task<IReadOnlyList<PartageSuiviResponseDto>> GetAll()
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

    public async Task<PartageSuiviResponseDto?> GetById(long id)
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

    public async Task<IdResponseDto> Create(UpsertPartageSuiviRequestDto dto)
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

    public async Task<bool> Update(long id, UpsertPartageSuiviRequestDto dto)
    {
        var entity = await _db.PartagesSuivi.FirstOrDefaultAsync(p => p.Id == id);
        if (entity == null) return false;

        entity.Autorisation = dto.Autorisation;
        entity.AineId = dto.AineId;
        entity.ProcheAidantId = dto.ProcheAidantId;

        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> Delete(long id)
    {
        var entity = await _db.PartagesSuivi.FirstOrDefaultAsync(p => p.Id == id);
        if (entity == null) return false;
        _db.PartagesSuivi.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }
}

