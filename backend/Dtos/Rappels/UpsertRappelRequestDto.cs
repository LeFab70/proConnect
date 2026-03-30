using System.ComponentModel.DataAnnotations;

namespace backend.Dtos.Rappels;

public class UpsertRappelRequestDto
{
    [Required(ErrorMessage = "La date et heure du rappel est obligatoire.")]
    public DateTime DateHeure { get; set; }

    [Required(ErrorMessage = "Le type de rappel est obligatoire.")]
    [MinLength(1, ErrorMessage = "Le type ne peut pas être vide.")]
    [MaxLength(32, ErrorMessage = "Le type ne doit pas dépasser 32 caractères.")]
    public required string Type { get; set; }

    public bool Actif { get; set; } = true;

    public long? MedicamentId { get; set; }
    public long? RendezVousMedicalId { get; set; }
}

