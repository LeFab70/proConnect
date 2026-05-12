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

    private static DateTime NormalizeUtc(DateTime dt)
    {
        // Npgsql (timestamptz) expects UTC DateTime. Flutter may send a value without timezone.
        return dt.Kind switch
        {
            DateTimeKind.Utc => dt,
            DateTimeKind.Local => dt.ToUniversalTime(),
            _ => DateTime.SpecifyKind(dt, DateTimeKind.Utc)
        };
    }

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

    public async Task<IReadOnlyList<RendezVousMedicalResponseDto>> GetForUser(long userId, string[] roles, CancellationToken ct = default)
    {
        var roleSet = new HashSet<string>(roles.Select(r => r.Trim().ToUpperInvariant()));
        var isAine = roleSet.Contains("AINE");

        IQueryable<RendezVousMedical> q = _db.RendezVousMedicaux.AsNoTracking();

        if (isAine)
        {
            q = q.Where(r => r.AineId == userId);
        }
        else
        {
            // For an aidant, return appointments for aînés they follow (partage actif).
            var aineIds = await _db.PartagesSuivi.AsNoTracking()
                .Where(p => p.ProcheAidantId == userId && p.Statut == "actif")
                .Select(p => p.AineId)
                .Distinct()
                .ToListAsync(ct);

            q = q.Where(r => aineIds.Contains(r.AineId));
        }

        return await q
            .OrderBy(r => r.DateHeure)
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
            .ToListAsync(ct);
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

    public async Task<RendezVousMedicalResponseDto> Create(UpsertRendezVousMedicalRequestDto dto, long userId, string[] roles, CancellationToken ct = default) // Crée un nouveau rendez-vous médical
    {
        var roleSet = new HashSet<string>(roles.Select(r => r.Trim().ToUpperInvariant()));
        var isAine = roleSet.Contains("AINE");

        if (isAine && dto.AineId != userId)
            throw new InvalidOperationException("Aîné non autorisé à créer un rendez-vous pour un autre utilisateur.");

        if (!isAine)
        {
            var can = await _db.PartagesSuivi.AsNoTracking()
                .AnyAsync(p => p.ProcheAidantId == userId && p.AineId == dto.AineId && p.Statut == "actif", ct);
            if (!can)
                throw new InvalidOperationException("Proche aidant non autorisé pour cet aîné.");
        }

        var entity = new RendezVousMedical
        {
            DateHeure = NormalizeUtc(dto.DateHeure),
            Lieu = new Adresse
            {
                // The Flutter app currently sends a single text field ("lieu").
                // Store it in Rue and keep other fields empty.
                Numero = string.Empty,
                Rue = dto.Lieu,
                Ville = string.Empty,
                CodePostal = string.Empty,
                Province = string.Empty
            },
            Docteur = dto.Docteur,
            Notes = dto.Notes,
            AineId = dto.AineId
        };
        _db.RendezVousMedicaux.Add(entity);
        await _db.SaveChangesAsync(ct);

        return new RendezVousMedicalResponseDto
        {
            Id = entity.Id,
            DateHeure = entity.DateHeure,
            Lieu = new AdresseDto
            {
                Numero = entity.Lieu.Numero,
                Rue = entity.Lieu.Rue,
                Ville = entity.Lieu.Ville,
                CodePostal = entity.Lieu.CodePostal,
                Province = entity.Lieu.Province
            },
            Docteur = entity.Docteur,
            Notes = entity.Notes,
            AineId = entity.AineId
        };
    }

    public async Task<bool> Update(long id, UpsertRendezVousMedicalRequestDto dto) // Met à jour un rendez-vous médical existant
    {
        var entity = await _db.RendezVousMedicaux.FirstOrDefaultAsync(r => r.Id == id);
        if (entity == null) return false;

        entity.DateHeure = NormalizeUtc(dto.DateHeure);
        entity.Lieu = new Adresse
        {
            Numero = string.Empty,
            Rue = dto.Lieu,
            Ville = string.Empty,
            CodePostal = string.Empty,
            Province = string.Empty
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