using System.ComponentModel.DataAnnotations;

namespace backend.Dtos.Partages;

public class UpsertPartageSuiviRequestDto
{
    [Required(ErrorMessage = "L'autorisation est obligatoire.")]
    [MinLength(1, ErrorMessage = "L'autorisation ne peut pas être vide.")]
    [MaxLength(100, ErrorMessage = "L'autorisation ne doit pas dépasser 100 caractères.")]
    public required string Autorisation { get; set; }

    [Range(1, long.MaxValue, ErrorMessage = "AineId doit être un identifiant valide (> 0).")]
    public long AineId { get; set; }

    [Range(1, long.MaxValue, ErrorMessage = "ProcheAidantId doit être un identifiant valide (> 0).")]
    public long ProcheAidantId { get; set; }
}

