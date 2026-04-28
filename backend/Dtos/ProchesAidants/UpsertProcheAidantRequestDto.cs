// DTO pour la création ou la mise à jour d'un proche aidant
using System.ComponentModel.DataAnnotations;
using backend.Dtos.Adresse;
using backend.Dtos.Partages; // Pour les annotations de validation des données

namespace backend.Dtos.ProchesAidants;

public class UpsertProcheAidantRequestDto
{
    [Required(ErrorMessage = "Le nom est obligatoire.")] // Validation pour s'assurer que le nom est fourni
    [MinLength(1, ErrorMessage = "Le nom ne peut pas être vide.")] // Validation pour s'assurer que le nom n'est pas une chaîne vide
    [MaxLength(100, ErrorMessage = "Le nom ne doit pas dépasser 100 caractères.")] // Validation pour s'assurer que le nom ne dépasse pas 100 caractères
    public required string Nom { get; set; } // Nom obligatoire entre 1 et 100 caractères

    [Required(ErrorMessage = "Le prénom est obligatoire.")] // Validation pour s'assurer que le prénom est fourni
    [MinLength(1, ErrorMessage = "Le prénom ne peut pas être vide.")] // Validation pour s'assurer que le prénom n'est pas une chaîne vide
    [MaxLength(100, ErrorMessage = "Le prénom ne doit pas dépasser 100 caractères.")] // Validation pour s'assurer que le prénom ne dépasse pas 100 caractères
    public required string Prenom { get; set; } // Prénom obligatoire entre 1 et 100 caractères

    [Required(ErrorMessage = "Le téléphone est obligatoire.")] // Validation pour s'assurer que le téléphone est fourni
    [Phone(ErrorMessage = "Le téléphone n'est pas valide.")] // Validation pour s'assurer que le téléphone est dans un format valide
    [MaxLength(30, ErrorMessage = "Le téléphone ne doit pas dépasser 30 caractères.")] // Validation pour s'assurer que le téléphone ne dépasse pas 30 caractères
    public required string Telephone { get; set; } // Téléphone obligatoire avec validation de format et longueur maximale de 30 caractères

    [Required(ErrorMessage = "L'email est obligatoire.")] // Validation pour s'assurer que l'email est fourni
    [EmailAddress(ErrorMessage = "L'email n'est pas valide.")] // Validation pour s'assurer que l'email est dans un format valide
    [MaxLength(200, ErrorMessage = "L'email ne doit pas dépasser 200 caractères.")] // Validation pour s'assurer que l'email ne dépasse pas 200 caractères
    public required string Email { get; set; } // Email obligatoire avec validation de format et longueur maximale de 200 caractères

    public AdresseDto? Adresse { get; set; }
}