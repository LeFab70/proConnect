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
    private readonly AppDbContext _db = db; // Injection du contexte de base de données

    public async Task<IReadOnlyList<RappelResponseDto>> GetAll() // Récupère tous les rappels
    {
        return await _db.Rappels
            .AsNoTracking()
            .OrderBy(r => r.Id)
            .Select(r => new RappelResponseDto
            {
                Id = r.Id,
                DateHeure = r.DateHeure,
                Type = r.Type,
                Actif = r.Actif,
                MedicamentId = r.MedicamentId,
                RendezVousMedicalId = r.RendezVousMedicalId
            })
            .ToListAsync();
    }

    public async Task<RappelResponseDto?> GetById(long id) // Récupère un rappel par son ID
    {
        return await _db.Rappels
            .AsNoTracking()
            .Where(r => r.Id == id)
            .Select(r => new RappelResponseDto
            {
                Id = r.Id,
                DateHeure = r.DateHeure,
                Type = r.Type,
                Actif = r.Actif,
                MedicamentId = r.MedicamentId,
                RendezVousMedicalId = r.RendezVousMedicalId
            })
            .FirstOrDefaultAsync();
    }

    public async Task<IdResponseDto> Create(UpsertRappelRequestDto dto) // Crée un nouveau rappel
    {
        var entity = new Rappel
        {
            DateHeure = dto.DateHeure,
            Type = dto.Type,
            Actif = dto.Actif,
            MedicamentId = dto.MedicamentId,
            RendezVousMedicalId = dto.RendezVousMedicalId
        };
        _db.Rappels.Add(entity);
        await _db.SaveChangesAsync();
        return new IdResponseDto { Id = entity.Id };
    }

    public async Task<bool> Update(long id, UpsertRappelRequestDto dto) // Met à jour un rappel existant
    {
        var entity = await _db.Rappels.FirstOrDefaultAsync(r => r.Id == id);
        if (entity == null) return false;

        entity.DateHeure = dto.DateHeure;
        entity.Type = dto.Type;
        entity.Actif = dto.Actif;
        entity.MedicamentId = dto.MedicamentId;
        entity.RendezVousMedicalId = dto.RendezVousMedicalId;

        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> Delete(long id) // Supprime un rappel par son ID
    {
        var entity = await _db.Rappels.FirstOrDefaultAsync(r => r.Id == id);
        if (entity == null) return false;
        _db.Rappels.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }
}