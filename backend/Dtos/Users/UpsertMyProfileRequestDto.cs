using System.ComponentModel.DataAnnotations;

namespace backend.Dtos.Users;

public class UpsertMyProfileRequestDto
{
    [Required(ErrorMessage = "Le nom est obligatoire.")]
    [MinLength(1, ErrorMessage = "Le nom ne peut pas être vide.")]
    [MaxLength(100, ErrorMessage = "Le nom ne doit pas dépasser 100 caractères.")]
    public required string Nom { get; set; }

    [Required(ErrorMessage = "Le prénom est obligatoire.")]
    [MinLength(1, ErrorMessage = "Le prénom ne peut pas être vide.")]
    [MaxLength(100, ErrorMessage = "Le prénom ne doit pas dépasser 100 caractères.")]
    public required string Prenom { get; set; }

    [Required(ErrorMessage = "Le téléphone est obligatoire.")]
    [Phone(ErrorMessage = "Le téléphone n'est pas valide.")]
    [MaxLength(30, ErrorMessage = "Le téléphone ne doit pas dépasser 30 caractères.")]
    public required string Telephone { get; set; }
}

