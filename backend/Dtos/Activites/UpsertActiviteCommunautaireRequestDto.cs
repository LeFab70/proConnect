// DTO pour la création ou la mise à jour d'une activité communautaire (A partir de HuggingFace AI)

using System.ComponentModel.DataAnnotations; // Utilisation de DataAnnotations pour la validation des propriétés (Messages d'erreur, contraintes de longueur, etc.)
using backend.Dtos.Adresse; // Importation du DTO pour l'adresse, utilisé pour le lieu de l'activité communautaire (Pour ne pas l'ajouter dans la base de données comme classe séparée, mais plutôt comme une propriété complexe de l'activité communautaire)

namespace backend.Dtos.Activites;

public class UpsertActiviteCommunautaireRequestDto
{
    [Required(ErrorMessage = "Le titre est obligatoire.")] // Titre de l'activité obligatoire
    [MinLength(1, ErrorMessage = "Le titre ne peut pas être vide.")] // Titre de l'activité doit contenir au moins 1 caractère
    [MaxLength(200, ErrorMessage = "Le titre ne doit pas dépasser 200 caractères.")] // Titre de l'activité ne doit pas dépasser 200 caractères
    public required string Titre { get; set; } // Titre de l'activité obligatoire, entre 1 et 200 caractères

    [Required(ErrorMessage = "La description est obligatoire.")] // Description de l'activité obligatoire
    [MinLength(1, ErrorMessage = "La description ne peut pas être vide.")] // Description de l'activité doit contenir au moins 1 caractère
    [MaxLength(2000, ErrorMessage = "La description ne doit pas dépasser 2000 caractères.")] // Description de l'activité ne doit pas dépasser 2000 caractères
    public required string Description { get; set; } // Description de l'activité obligatoire, entre 1 et 2000 caractères

    [Required(ErrorMessage = "La date et heure est obligatoire.")] // Date et heure de l'activité obligatoire
    public DateTime DateHeure { get; set; } // Date et heure de l'activité obligatoire

    [Required(ErrorMessage = "L'adresse du lieu est obligatoire.")] // Adresse du lieu de l'activité obligatoire
    public AdresseDto Lieu { get; set; } // Lieu de l'activité obligatoire

    [Range(1, long.MaxValue, ErrorMessage = "CalendrierCommunautaireId doit être un identifiant valide (> 0).")] // CalendrierCommunautaireId doit être un identifiant valide (supérieur à 0)
    public long CalendrierCommunautaireId { get; set; } // Identifiant du calendrier communautaire obligatoire
}