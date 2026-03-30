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

    public async Task<UserResponseDto?> GetById(long id)
    {
        return await _db.Users
            .AsNoTracking()
            .Where(u => u.Id == id)
            .Select(u => new UserResponseDto
            {
                Id = u.Id,
                Nom = u.Nom,
                Prenom = u.Prenom,
                Telephone = u.Telephone,
                Email = u.Email,
                Role = u.Role
            })
            .FirstOrDefaultAsync();
    }

    public async Task<IdResponseDto> Create(UpsertUserRequestDto dto)
    {
        var entity = new User
        {
            Nom = dto.Nom,
            Prenom = dto.Prenom,
            Telephone = dto.Telephone,
            Email = dto.Email,
            Role = dto.Role
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
        entity.Role = dto.Role;

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