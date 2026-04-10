using System.ComponentModel.DataAnnotations;

namespace backend.Dtos.Users;

public class UpsertUserRequestDto
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

    [MinLength(3, ErrorMessage = "Le rôle doit contenir au moins 3 caractères.")]
    [MaxLength(32, ErrorMessage = "Le rôle ne doit pas dépasser 32 caractères.")]
    public string? Role { get; set; }
}

