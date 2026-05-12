using backend.Dtos.Common;
using backend.Dtos.Partages;
using backend.Infrastructure;
using backend.Models;
using backend.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace backend.Services;

// Service pour gérer les partages de suivi entre aînés et proches aidants
public class PartageSuiviService(AppDbContext db) : IPartageSuiviService
{
    private readonly AppDbContext _db = db; // Injection du contexte de base de données

    public async Task<IReadOnlyList<PartageSuiviResponseDto>> GetAll()
    {
        return await (
            from p in _db.PartagesSuivi.AsNoTracking()
            join aine in _db.Users.AsNoTracking() on p.AineId equals aine.Id
            join proche in _db.Users.AsNoTracking() on p.ProcheAidantId equals proche.Id into procheGroup
            from proche in procheGroup.DefaultIfEmpty()
            orderby p.Id
            select new PartageSuiviResponseDto
            {
                Id = p.Id,
                Autorisation = p.Autorisation,
                Relation = p.Relation,
                AineId = p.AineId,
                AineNom = aine.Nom,
                AinePrenom = aine.Prenom,
                ProcheAidantId = p.ProcheAidantId,
                ProcheNom = proche != null ? proche.Nom : null,
                ProchePrenom = proche != null ? proche.Prenom : null,
                ProcheEmail = p.ProcheEmail,
                Statut = p.Statut,
                CreatedAtUtc = p.CreatedAtUtc
            }
        ).ToListAsync();
    }

    public async Task<IReadOnlyList<PartageSuiviResponseDto>> GetForUser(long userId, string userEmail, string[] roles, CancellationToken ct = default)
    {
        var roleSet = new HashSet<string>(roles.Select(r => r.Trim().ToUpperInvariant()));
        var isAine = roleSet.Contains("AINE");
        var emailLower = userEmail?.Trim().ToLowerInvariant() ?? "";

        var baseQuery = from p in _db.PartagesSuivi.AsNoTracking()
                        join aine in _db.Users.AsNoTracking() on p.AineId equals aine.Id
                        join proche in _db.Users.AsNoTracking() on p.ProcheAidantId equals proche.Id into procheGroup
                        from proche in procheGroup.DefaultIfEmpty()
                        select new { p, aine, proche };

        var filtered = isAine
            ? baseQuery.Where(x => x.p.AineId == userId)
            : baseQuery.Where(x =>
                x.p.ProcheAidantId == userId ||
                (x.p.ProcheEmail != null && x.p.ProcheEmail.ToLower() == emailLower));

        return await filtered
            .OrderBy(x => x.p.Id)
            .Select(x => new PartageSuiviResponseDto
            {
                Id = x.p.Id,
                Autorisation = x.p.Autorisation,
                Relation = x.p.Relation,
                AineId = x.p.AineId,
                AineNom = x.aine.Nom,
                AinePrenom = x.aine.Prenom,
                ProcheAidantId = x.p.ProcheAidantId,
                ProcheNom = x.proche != null ? x.proche.Nom : null,
                ProchePrenom = x.proche != null ? x.proche.Prenom : null,
                ProcheEmail = x.p.ProcheEmail,
                Statut = x.p.Statut,
                CreatedAtUtc = x.p.CreatedAtUtc
            })
            .ToListAsync(ct);
    }

    public async Task<PartageSuiviResponseDto?> GetById(long id)
    {
        return await (
            from p in _db.PartagesSuivi.AsNoTracking()
            where p.Id == id
            join aine in _db.Users.AsNoTracking() on p.AineId equals aine.Id
            join proche in _db.Users.AsNoTracking() on p.ProcheAidantId equals proche.Id into procheGroup
            from proche in procheGroup.DefaultIfEmpty()
            select new PartageSuiviResponseDto
            {
                Id = p.Id,
                Autorisation = p.Autorisation,
                Relation = p.Relation,
                AineId = p.AineId,
                AineNom = aine.Nom,
                AinePrenom = aine.Prenom,
                ProcheAidantId = p.ProcheAidantId,
                ProcheNom = proche != null ? proche.Nom : null,
                ProchePrenom = proche != null ? proche.Prenom : null,
                ProcheEmail = p.ProcheEmail,
                Statut = p.Statut,
                CreatedAtUtc = p.CreatedAtUtc
            }
        ).FirstOrDefaultAsync();
    }

    public async Task<IdResponseDto> Create(UpsertPartageSuiviRequestDto dto) // Crée un nouveau partage de suivi
    {
        var entity = new PartageSuivi
        {
            Autorisation = dto.Autorisation,
            Relation = dto.Relation,
            AineId = dto.AineId,
            ProcheAidantId = dto.ProcheAidantId,
            ProcheEmail = string.IsNullOrWhiteSpace(dto.ProcheEmail) ? null : dto.ProcheEmail.Trim().ToLowerInvariant(),
            Statut = "enAttente",
            CreatedAtUtc = DateTime.UtcNow
        };
        _db.PartagesSuivi.Add(entity);
        await _db.SaveChangesAsync();
        return new IdResponseDto { Id = entity.Id };
    }

    public async Task<bool> Update(long id, UpsertPartageSuiviRequestDto dto)
    {
        var entity = await _db.PartagesSuivi.FirstOrDefaultAsync(p => p.Id == id);
        if (entity == null) return false;

        // Seuls l'autorisation et la relation peuvent être modifiées — jamais les IDs ni le statut.
        entity.Autorisation = dto.Autorisation;
        entity.Relation = dto.Relation;

        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> Delete(long id) // Supprime un partage de suivi par son ID
    {
        var entity = await _db.PartagesSuivi.FirstOrDefaultAsync(p => p.Id == id);
        if (entity == null) return false;
        _db.PartagesSuivi.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }
}