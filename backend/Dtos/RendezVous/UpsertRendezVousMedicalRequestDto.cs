using System.ComponentModel.DataAnnotations;
using backend.Dtos.Adresse;

namespace backend.Dtos.RendezVous;

public class UpsertRendezVousMedicalRequestDto
{
    [Required(ErrorMessage = "La date et heure du rendez-vous est obligatoire.")]
    public DateTime DateHeure { get; set; }

    [Required(ErrorMessage = "Le lieu est obligatoire.")]
    public required AdresseDto Lieu { get; set; }

    [Required(ErrorMessage = "Le docteur est obligatoire.")]
    [MinLength(1, ErrorMessage = "Le docteur ne peut pas être vide.")]
    [MaxLength(200, ErrorMessage = "Le docteur ne doit pas dépasser 200 caractères.")]
    public required string Docteur { get; set; }

    [MaxLength(1000, ErrorMessage = "Les notes ne doivent pas dépasser 1000 caractères.")]
    public string? Notes { get; set; }

    [Range(1, long.MaxValue, ErrorMessage = "AineId doit être un identifiant valide (> 0).")]
    public long AineId { get; set; }
}

