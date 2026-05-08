// DTO pour la création ou la mise à jour d'un partage de suivi entre un aîné et un proche aidant.
using System.ComponentModel.DataAnnotations; // Importation de data annotations pour la validation des propriétés du DTO.

namespace backend.Dtos.Partages;

public class UpsertPartageSuiviRequestDto
{
    [Required(ErrorMessage = "L'autorisation est obligatoire.")] // Indique que la propriété Autorisation est obligatoire.
    [MinLength(1, ErrorMessage = "L'autorisation ne peut pas être vide.")] // Indique que la propriété Autorisation doit contenir au moins 1 caractère.
    [MaxLength(100, ErrorMessage = "L'autorisation ne doit pas dépasser 100 caractères.")] // Indique que la propriété Autorisation ne doit pas dépasser 100 caractères.
    public required string Autorisation { get; set; } // Autorisation obligatoire entre 1 et 100 caractères.

    [Required(ErrorMessage = "La relation est obligatoire.")] // Indique que la propriété Relation est obligatoire.
    [MinLength(1, ErrorMessage = "La relation ne peut pas être vide.")] // Indique que la propriété Relation doit contenir au moins 1 caractère.
    [MaxLength(100, ErrorMessage = "La relation ne doit pas dépasser 100 caractères.")] // Indique que la propriété Relation ne doit pas dépasser 100 caractères.
    public required string Relation { get; set; } // Relation obligatoire entre 1 et 100 caractères (ex: "Fils", "Fille", "Conjoint", etc.).

    [Range(1, long.MaxValue, ErrorMessage = "AineId doit être un identifiant valide (> 0).")] // Indique que la propriété AineId doit être un entier positif supérieur à 0.
    public long AineId { get; set; } // Identifiant de l'aîné, doit être un entier positif supérieur à 0.

    // Invitation possible par id OU par email
    public long? ProcheAidantId { get; set; }
    public string? ProcheEmail { get; set; }
}