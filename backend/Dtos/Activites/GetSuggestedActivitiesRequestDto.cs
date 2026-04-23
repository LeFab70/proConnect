using System.ComponentModel.DataAnnotations;

namespace backend.Dtos.Activites;

public class GetSuggestedActivitiesRequestDto
{
    [Required(ErrorMessage = "L'adresse est obligatoire.")]
    [MinLength(3, ErrorMessage = "L'adresse doit contenir au moins 3 caractères.")]
    [MaxLength(300, ErrorMessage = "L'adresse ne doit pas dépasser 300 caractères.")]
    public required string Adresse { get; set; }

    [MaxLength(200, ErrorMessage = "Les centres d'intérêt ne doivent pas dépasser 200 caractères.")]
    public string? Interets { get; set; } // ex: "marche, bingo, yoga doux"

    [Range(1, 50, ErrorMessage = "Le nombre de suggestions doit être entre 1 et 50.")]
    public int Limit { get; set; } = 10;
}

