using backend.Dtos.Aines;
using backend.Dtos.Common;
using backend.Infrastructure;
using backend.Models;
using backend.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace backend.Services;

public class AineService(AppDbContext db) : IAineService
{
    private readonly AppDbContext _db = db;

    public async Task<IReadOnlyList<AineResponseDto>> GetAll()
    {
        return await _db.Aines
            .AsNoTracking()
            .OrderBy(a => a.Id)
            .Select(a => new AineResponseDto
            {
                Id = a.Id,
                Nom = a.Nom,
                Prenom = a.Prenom,
                Telephone = a.Telephone,
                Email = a.Email,
                DateNaissance = a.DateNaissance,
                Adresse = a.Adresse
            })
            .ToListAsync();
    }

    public async Task<AineResponseDto?> GetById(long id)
    {
        return await _db.Aines
            .AsNoTracking()
            .Where(a => a.Id == id)
            .Select(a => new AineResponseDto
            {
                Id = a.Id,
                Nom = a.Nom,
                Prenom = a.Prenom,
                Telephone = a.Telephone,
                Email = a.Email,
                DateNaissance = a.DateNaissance,
                Adresse = a.Adresse
            })
            .FirstOrDefaultAsync();
    }

    public async Task<IdResponseDto> Create(UpsertAineRequestDto dto)
    {
        var entity = new Aine
        {
            Nom = dto.Nom,
            Prenom = dto.Prenom,
            Telephone = dto.Telephone,
            Email = dto.Email,
            PasswordHash = "N/A",
            DateNaissance = dto.DateNaissance,
            Adresse = dto.Adresse
        };
        _db.Aines.Add(entity);
        await _db.SaveChangesAsync();
        return new IdResponseDto { Id = entity.Id };
    }

    public async Task<bool> Update(long id, UpsertAineRequestDto dto)
    {
        var entity = await _db.Aines.FirstOrDefaultAsync(a => a.Id == id);
        if (entity == null) return false;

        entity.Nom = dto.Nom;
        entity.Prenom = dto.Prenom;
        entity.Telephone = dto.Telephone;
        entity.Email = dto.Email;
        entity.DateNaissance = dto.DateNaissance;
        entity.Adresse = dto.Adresse;

        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> Delete(long id)
    {
        var entity = await _db.Aines.FirstOrDefaultAsync(a => a.Id == id);
        if (entity == null) return false;
        _db.Aines.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }
}

