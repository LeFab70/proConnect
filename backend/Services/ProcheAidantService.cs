using backend.Dtos.Common;
using backend.Dtos.ProchesAidants;
using backend.Infrastructure;
using backend.Models;
using backend.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace backend.Services;

// Service pour gérer les proches aidants
public class ProcheAidantService(AppDbContext db) : IProcheAidantService
{
    private readonly AppDbContext _db = db; // Injection de dépendance du contexte de base de données

    public async Task<IReadOnlyList<ProcheAidantResponseDto>> GetAll() // Récupère tous les proches aidants
    {
        return await _db.ProchesAidants
            .AsNoTracking()
            .OrderBy(p => p.Id)
            .Select(p => new ProcheAidantResponseDto
            {
                Id = p.Id,
                Nom = p.Nom,
                Prenom = p.Prenom,
                Telephone = p.Telephone,
                Email = p.Email,
                Relation = p.Relation
            })
            .ToListAsync();
    }

    public async Task<ProcheAidantResponseDto?> GetById(long id) // Récupère un proche aidant par son ID
    {
        return await _db.ProchesAidants
            .AsNoTracking()
            .Where(p => p.Id == id)
            .Select(p => new ProcheAidantResponseDto
            {
                Id = p.Id,
                Nom = p.Nom,
                Prenom = p.Prenom,
                Telephone = p.Telephone,
                Email = p.Email,
                Relation = p.Relation
            })
            .FirstOrDefaultAsync();
    }

    public async Task<IdResponseDto> Create(UpsertProcheAidantRequestDto dto) // Crée un nouveau proche aidant
    {
        var entity = new ProcheAidant
        {
            KeycloakId = Guid.NewGuid().ToString(),
            Nom = dto.Nom,
            Prenom = dto.Prenom,
            Telephone = dto.Telephone,
            Email = dto.Email,
            Relation = dto.Relation
        };
        _db.ProchesAidants.Add(entity);
        await _db.SaveChangesAsync();
        return new IdResponseDto { Id = entity.Id };
    }

    public async Task<bool> Update(long id, UpsertProcheAidantRequestDto dto) // Met à jour un proche aidant existant
    {
        var entity = await _db.ProchesAidants.FirstOrDefaultAsync(p => p.Id == id);
        if (entity == null) return false;

        entity.Nom = dto.Nom;
        entity.Prenom = dto.Prenom;
        entity.Telephone = dto.Telephone;
        entity.Email = dto.Email;
        entity.Relation = dto.Relation;

        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> Delete(long id) // Supprime un proche aidant par son ID
    {
        var entity = await _db.ProchesAidants.FirstOrDefaultAsync(p => p.Id == id);
        if (entity == null) return false;
        _db.ProchesAidants.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }
}