using System.ComponentModel.DataAnnotations;

namespace backend.Dtos.Aines;

public class UpsertAineRequestDto
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

    [Required(ErrorMessage = "L'email est obligatoire.")]
    [EmailAddress(ErrorMessage = "L'email n'est pas valide.")]
    [MaxLength(200, ErrorMessage = "L'email ne doit pas dépasser 200 caractères.")]
    public required string Email { get; set; }

    [Required(ErrorMessage = "La date de naissance est obligatoire.")]
    public DateOnly DateNaissance { get; set; }

    [Required(ErrorMessage = "L'adresse est obligatoire.")]
    [MinLength(3, ErrorMessage = "L'adresse doit contenir au moins 3 caractères.")]
    [MaxLength(300, ErrorMessage = "L'adresse ne doit pas dépasser 300 caractères.")]
    public required string Adresse { get; set; }
}

