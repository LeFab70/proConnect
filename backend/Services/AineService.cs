using backend.Dtos.Aines;
using backend.Dtos.Common;
using backend.Infrastructure;
using backend.Models;
using backend.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace backend.Services;

// Service pour gérer les opérations CRUD sur les aînés
public class AineService(AppDbContext db) : IAineService
{
    private readonly AppDbContext _db = db; // Injection de dépendance du contexte de base de données

    public async Task<IReadOnlyList<AineResponseDto>> GetAll() // Récupère tous les aînés de la base de données et les mappe en DTOs
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
                Adresse = a.Adresse,
                Docteur = a.Docteur,
                NumeroTelephoneDocteur = a.NumeroTelephoneDocteur
            })
            .ToListAsync();
    }

    public async Task<AineResponseDto?> GetById(long id) // Récupère un aîné spécifique par son ID et le mappe en DTO
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
                Adresse = a.Adresse,
                Docteur = a.Docteur,
                NumeroTelephoneDocteur = a.NumeroTelephoneDocteur
            })
            .FirstOrDefaultAsync();
    }

    public async Task<IdResponseDto> Create(UpsertAineRequestDto dto) // Crée un nouvel aîné à partir des données fournies dans le DTO et retourne l'ID de l'entité créée
    {
        var entity = new Aine
        {
            KeycloakId = Guid.NewGuid().ToString(),
            Nom = dto.Nom,
            Prenom = dto.Prenom,
            Telephone = dto.Telephone,
            Email = dto.Email,
            DateNaissance = dto.DateNaissance,
            Adresse = dto.Adresse,
            Docteur = dto.Docteur,
            NumeroTelephoneDocteur = dto.NumeroTelephoneDocteur
        };
        _db.Aines.Add(entity);
        await _db.SaveChangesAsync();
        return new IdResponseDto { Id = entity.Id };
    }

    public async Task<bool> Update(long id, UpsertAineRequestDto dto) // Met à jour un aîné existant avec les nouvelles données fournies dans le DTO, retourne true si la mise à jour a réussi, sinon false si l'aîné n'existe pas
    {
        var entity = await _db.Aines.FirstOrDefaultAsync(a => a.Id == id);
        if (entity == null) return false;

        entity.Nom = dto.Nom;
        entity.Prenom = dto.Prenom;
        entity.Telephone = dto.Telephone;
        entity.Email = dto.Email;
        entity.DateNaissance = dto.DateNaissance;
        entity.Adresse = dto.Adresse;
        entity.Docteur = dto.Docteur;
        entity.NumeroTelephoneDocteur = dto.NumeroTelephoneDocteur;

        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> Delete(long id) // Supprime un aîné de la base de données en fonction de son ID, retourne true si la suppression a réussi, sinon false si l'aîné n'existe pas
    {
        var entity = await _db.Aines.FirstOrDefaultAsync(a => a.Id == id);
        if (entity == null) return false;
        _db.Aines.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }
}