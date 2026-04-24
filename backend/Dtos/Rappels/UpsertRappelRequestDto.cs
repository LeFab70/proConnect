// DTO pour la création ou la mise à jour d'un rappel
using System.ComponentModel.DataAnnotations; // Utilisation de DataAnnotations pour la validation des données d'entrée

namespace backend.Dtos.Rappels;

public class UpsertRappelRequestDto
{
    // Propriétés du DTO pour la création ou la mise à jour d'un rappel
    [Required(ErrorMessage = "La date et heure du rappel est obligatoire.")] // Validation pour s'assurer que la date et heure du rappel est fournie
    public DateTime DateHeure { get; set; } // Propriété pour la date et heure du rappel

    [Required(ErrorMessage = "Le type de rappel est obligatoire.")] // Validation pour s'assurer que le type de rappel est fourni
    [MinLength(1, ErrorMessage = "Le type ne peut pas être vide.")] // Validation pour s'assurer que le type de rappel n'est pas vide
    [MaxLength(32, ErrorMessage = "Le type ne doit pas dépasser 32 caractères.")] // Validation pour s'assurer que le type de rappel ne dépasse pas 32 caractères
    public required string Type { get; set; } // Propriété pour le type de rappel (ex: "Médicament", "Rendez-vous médical")

    public bool Actif { get; set; } = true; // Propriété pour indiquer si le rappel est actif ou non, par défaut à true

    public long? MedicamentId { get; set; } // Propriété pour la clé étrangère vers le médicament associé au rappel, nullable car un rappel peut ne pas être lié à un médicament
    public long? RendezVousMedicalId { get; set; } // Propriété pour la clé étrangère vers le rendez-vous médical associé au rappel, nullable car un rappel peut ne pas être lié à un rendez-vous médical
}