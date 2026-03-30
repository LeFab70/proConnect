using System.ComponentModel.DataAnnotations;

namespace backend.Dtos.Activites;

public class UpsertActiviteCommunautaireRequestDto
{
    [Required(ErrorMessage = "Le titre est obligatoire.")]
    [MinLength(1, ErrorMessage = "Le titre ne peut pas être vide.")]
    [MaxLength(200, ErrorMessage = "Le titre ne doit pas dépasser 200 caractères.")]
    public required string Titre { get; set; }

    [Required(ErrorMessage = "La description est obligatoire.")]
    [MinLength(1, ErrorMessage = "La description ne peut pas être vide.")]
    [MaxLength(2000, ErrorMessage = "La description ne doit pas dépasser 2000 caractères.")]
    public required string Description { get; set; }

    [Required(ErrorMessage = "La date et heure est obligatoire.")]
    public DateTime DateHeure { get; set; }

    [Required(ErrorMessage = "Le lieu est obligatoire.")]
    [MinLength(1, ErrorMessage = "Le lieu ne peut pas être vide.")]
    [MaxLength(200, ErrorMessage = "Le lieu ne doit pas dépasser 200 caractères.")]
    public required string Lieu { get; set; }

    [Range(1, long.MaxValue, ErrorMessage = "CalendrierCommunautaireId doit être un identifiant valide (> 0).")]
    public long CalendrierCommunautaireId { get; set; }
}

