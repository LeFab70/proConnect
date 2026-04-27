using System.ComponentModel.DataAnnotations;

namespace backend.Dtos.Rappels;

public class UpsertRappelRequestDto
{
    [Required(ErrorMessage = "La date de début est obligatoire.")]
    public DateOnly DateDebut { get; set; }

    [Required(ErrorMessage = "L'heure de début est obligatoire.")]
    public TimeOnly HeureDebut { get; set; }

    [Range(0, 10080, ErrorMessage = "MinutesAvantRappel doit être entre 0 (à l'heure exacte) et 10080 (7 jours avant).")]
    public int MinutesAvantRappel { get; set; }

    [Required(ErrorMessage = "Le type de rappel est obligatoire.")]
    [MinLength(1, ErrorMessage = "Le type ne peut pas être vide.")]
    [MaxLength(32, ErrorMessage = "Le type ne doit pas dépasser 32 caractères.")]
    public required string Type { get; set; }

    public bool Actif { get; set; } = true;

    public long? MedicamentId { get; set; }
    public long? RendezVousMedicalId { get; set; }
}
