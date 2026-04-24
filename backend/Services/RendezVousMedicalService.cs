using backend.Dtos.Common;
using backend.Dtos.RendezVous;
using backend.Dtos.Adresse;
using backend.Infrastructure;
using backend.Models;
using backend.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace backend.Services;

// Service pour gérer les rendez-vous médicaux des aînés
public class RendezVousMedicalService(AppDbContext db) : IRendezVousMedicalService
{
    private readonly AppDbContext _db = db; // Injection de dépendance du contexte de base de données

    public async Task<IReadOnlyList<RendezVousMedicalResponseDto>> GetAll() // Récupère tous les rendez-vous médicaux
    {
        return await _db.RendezVousMedicaux
            .AsNoTracking()
            .OrderBy(r => r.Id)
            .Select(r => new RendezVousMedicalResponseDto
            {
                Id = r.Id,
                DateHeure = r.DateHeure,
                Lieu = new AdresseDto
                {
                    Numero = r.Lieu.Numero,
                    Rue = r.Lieu.Rue,
                    Ville = r.Lieu.Ville,
                    CodePostal = r.Lieu.CodePostal,
                    Province = r.Lieu.Province
                },
                Docteur = r.Docteur,
                Notes = r.Notes,
                AineId = r.AineId
            })
            .ToListAsync();
    }

    public async Task<RendezVousMedicalResponseDto?> GetById(long id) // Récupère un rendez-vous médical par son ID
    {
        return await _db.RendezVousMedicaux
            .AsNoTracking()
            .Where(r => r.Id == id)
            .Select(r => new RendezVousMedicalResponseDto
            {
                Id = r.Id,
                DateHeure = r.DateHeure,
                Lieu = new AdresseDto
                {
                    Numero = r.Lieu.Numero,
                    Rue = r.Lieu.Rue,
                    Ville = r.Lieu.Ville,
                    CodePostal = r.Lieu.CodePostal,
                    Province = r.Lieu.Province
                },
                Docteur = r.Docteur,
                Notes = r.Notes,
                AineId = r.AineId
            })
            .FirstOrDefaultAsync();
    }

    public async Task<IdResponseDto> Create(UpsertRendezVousMedicalRequestDto dto) // Crée un nouveau rendez-vous médical
    {
        var entity = new RendezVousMedical
        {
            DateHeure = dto.DateHeure,
            Lieu = new Adresse
            {
                Numero = dto.Lieu.Numero,
                Rue = dto.Lieu.Rue,
                Ville = dto.Lieu.Ville,
                CodePostal = dto.Lieu.CodePostal,
                Province = dto.Lieu.Province
            },
            Docteur = dto.Docteur,
            Notes = dto.Notes,
            AineId = dto.AineId
        };
        _db.RendezVousMedicaux.Add(entity);
        await _db.SaveChangesAsync();
        return new IdResponseDto { Id = entity.Id };
    }

    public async Task<bool> Update(long id, UpsertRendezVousMedicalRequestDto dto) // Met à jour un rendez-vous médical existant
    {
        var entity = await _db.RendezVousMedicaux.FirstOrDefaultAsync(r => r.Id == id);
        if (entity == null) return false;

        entity.DateHeure = dto.DateHeure;
        entity.Lieu = new Adresse
        {
            Numero = dto.Lieu.Numero,
            Rue = dto.Lieu.Rue,
            Ville = dto.Lieu.Ville,
            CodePostal = dto.Lieu.CodePostal,
            Province = dto.Lieu.Province
        };
        entity.Docteur = dto.Docteur;
        entity.Notes = dto.Notes;
        entity.AineId = dto.AineId;

        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> Delete(long id) // Supprime un rendez-vous médical par son ID
    {
        var entity = await _db.RendezVousMedicaux.FirstOrDefaultAsync(r => r.Id == id);
        if (entity == null) return false;
        _db.RendezVousMedicaux.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }
}