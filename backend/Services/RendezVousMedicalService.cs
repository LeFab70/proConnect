using backend.Dtos.Common;
using backend.Dtos.RendezVous;
using backend.Infrastructure;
using backend.Models;
using backend.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace backend.Services;

public class RendezVousMedicalService(AppDbContext db) : IRendezVousMedicalService
{
    private readonly AppDbContext _db = db;

    public async Task<RendezVousMedicalResponseDto?> GetById(long id)
    {
        return await _db.RendezVousMedicaux
            .AsNoTracking()
            .Where(r => r.Id == id)
            .Select(r => new RendezVousMedicalResponseDto
            {
                Id = r.Id,
                DateHeure = r.DateHeure,
                Lieu = r.Lieu,
                Specialiste = r.Specialiste,
                Notes = r.Notes,
                AineId = r.AineId
            })
            .FirstOrDefaultAsync();
    }

    public async Task<IdResponseDto> Create(UpsertRendezVousMedicalRequestDto dto)
    {
        var entity = new RendezVousMedical
        {
            DateHeure = dto.DateHeure,
            Lieu = dto.Lieu,
            Specialiste = dto.Specialiste,
            Notes = dto.Notes,
            AineId = dto.AineId
        };
        _db.RendezVousMedicaux.Add(entity);
        await _db.SaveChangesAsync();
        return new IdResponseDto { Id = entity.Id };
    }

    public async Task<bool> Update(long id, UpsertRendezVousMedicalRequestDto dto)
    {
        var entity = await _db.RendezVousMedicaux.FirstOrDefaultAsync(r => r.Id == id);
        if (entity == null) return false;

        entity.DateHeure = dto.DateHeure;
        entity.Lieu = dto.Lieu;
        entity.Specialiste = dto.Specialiste;
        entity.Notes = dto.Notes;
        entity.AineId = dto.AineId;

        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> Delete(long id)
    {
        var entity = await _db.RendezVousMedicaux.FirstOrDefaultAsync(r => r.Id == id);
        if (entity == null) return false;
        _db.RendezVousMedicaux.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }
}

