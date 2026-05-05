using System.ComponentModel.DataAnnotations;

namespace backend.Dtos.Medicaments;

public class UpsertMedicamentRequestDto
{
    [Required(ErrorMessage = "Le nom du médicament est obligatoire.")]
    [MinLength(1, ErrorMessage = "Le nom du médicament ne peut pas être vide.")]
    [MaxLength(200, ErrorMessage = "Le nom du médicament ne doit pas dépasser 200 caractères.")]
    public required string Nom { get; set; }

    [Required(ErrorMessage = "La marque du médicament est obligatoire.")]
    [MinLength(1, ErrorMessage = "La marque du médicament ne peut pas être vide.")]
    [MaxLength(100, ErrorMessage = "La marque du médicament ne doit pas dépasser 100 caractères.")]
    public required string Marque { get; set; }

    [Required(ErrorMessage = "Le dosage est obligatoire.")]
    [MinLength(1, ErrorMessage = "Le dosage ne peut pas être vide.")]
    [MaxLength(100, ErrorMessage = "Le dosage ne doit pas dépasser 100 caractères.")]
    public required string Dosage { get; set; }

    [Required(ErrorMessage = "La fréquence est obligatoire.")]
    [MinLength(1, ErrorMessage = "La fréquence ne peut pas être vide.")]
    [MaxLength(100, ErrorMessage = "La fréquence ne doit pas dépasser 100 caractères.")]
    public required string Frequence { get; set; }

    [Range(1, long.MaxValue, ErrorMessage = "AineId doit être un identifiant valide (> 0).")]
    public long AineId { get; set; }

    [Url(ErrorMessage = "UrlPhoto doit être une URL valide.")]
    [MaxLength(1000, ErrorMessage = "UrlPhoto ne doit pas dépasser 1000 caractères.")]
    public string? UrlPhoto { get; set; }

    public bool? IsActive { get; set; }
}
