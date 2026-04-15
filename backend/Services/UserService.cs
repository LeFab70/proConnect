using backend.Dtos.Common;
using backend.Dtos.Users;
using backend.Infrastructure;
using backend.Models;
using backend.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace backend.Services;

public class UserService(AppDbContext db) : IUserService
{
    private readonly AppDbContext _db = db;

    public async Task<IReadOnlyList<UserResponseDto>> GetAll()
    {
        return await _db.Users
            .AsNoTracking()
            .OrderBy(u => u.Id)
            .Select(u => new UserResponseDto
            {
                Id = u.Id,
                KeycloakId = u.KeycloakId,
                Nom = u.Nom,
                Prenom = u.Prenom,
                Telephone = u.Telephone,
                Email = u.Email
            })
            .ToListAsync();
    }

    public async Task<UserResponseDto?> GetById(long id)
    {
        return await _db.Users
            .AsNoTracking()
            .Where(u => u.Id == id)
            .Select(u => new UserResponseDto
            {
                Id = u.Id,
                KeycloakId = u.KeycloakId,
                Nom = u.Nom,
                Prenom = u.Prenom,
                Telephone = u.Telephone,
                Email = u.Email
            })
            .FirstOrDefaultAsync();
    }

    public async Task<UserResponseDto> GetOrCreateMe(string keycloakId, string email, string? nom, string? prenom)
    {
        var existing = await _db.Users.AsNoTracking()
            .Where(u => u.KeycloakId == keycloakId)
            .Select(u => new UserResponseDto
            {
                Id = u.Id,
                KeycloakId = u.KeycloakId,
                Nom = u.Nom,
                Prenom = u.Prenom,
                Telephone = u.Telephone,
                Email = u.Email
            })
            .FirstOrDefaultAsync();

        if (existing != null) return existing;

        var entity = new StandardUser
        {
            KeycloakId = keycloakId,
            Email = email,
            Nom = nom ?? "Inconnu",
            Prenom = prenom ?? "Inconnu",
            Telephone = "N/A"
        };
        _db.Users.Add(entity);
        await _db.SaveChangesAsync();

        return new UserResponseDto
        {
            Id = entity.Id,
            KeycloakId = entity.KeycloakId,
            Nom = entity.Nom,
            Prenom = entity.Prenom,
            Telephone = entity.Telephone,
            Email = entity.Email
        };
    }

    public async Task<bool> UpdateMe(string keycloakId, UpsertMyProfileRequestDto dto)
    {
        var entity = await _db.Users.FirstOrDefaultAsync(u => u.KeycloakId == keycloakId);
        if (entity == null) return false;

        entity.Nom = dto.Nom;
        entity.Prenom = dto.Prenom;
        entity.Telephone = dto.Telephone;
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<IdResponseDto> Create(UpsertUserRequestDto dto)
    {
        var entity = new StandardUser
        {
            KeycloakId = dto.KeycloakId,
            Nom = dto.Nom,
            Prenom = dto.Prenom,
            Telephone = dto.Telephone,
            Email = dto.Email,
        };
        _db.Users.Add(entity);
        await _db.SaveChangesAsync();
        return new IdResponseDto { Id = entity.Id };
    }

    public async Task<bool> Update(long id, UpsertUserRequestDto dto)
    {
        var entity = await _db.Users.FirstOrDefaultAsync(u => u.Id == id);
        if (entity == null) return false;

        entity.Nom = dto.Nom;
        entity.Prenom = dto.Prenom;
        entity.Telephone = dto.Telephone;
        entity.Email = dto.Email;
        entity.KeycloakId = dto.KeycloakId;

        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> Delete(long id)
    {
        var entity = await _db.Users.FirstOrDefaultAsync(u => u.Id == id);
        if (entity == null) return false;
        _db.Users.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }
}