// DTO de requête pour la création ou la mise à jour d'un médicament
using System.ComponentModel.DataAnnotations; // Importation de data annotations pour les validations des propriétés du DTO

namespace backend.Dtos.Medicaments;

public class UpsertMedicamentRequestDto
{
    [Required(ErrorMessage = "Le nom du médicament est obligatoire.")] // Validation pour s'assurer que le nom est fourni
    [MinLength(1, ErrorMessage = "Le nom du médicament ne peut pas être vide.")] // Validation pour s'assurer que le nom n'est pas une chaîne vide
    [MaxLength(200, ErrorMessage = "Le nom du médicament ne doit pas dépasser 200 caractères.")] // Validation pour limiter la longueur du nom à 200 caractères
    public required string Nom { get; set; } // Nom du médicament, requis entre 1 et 200 caractères

    [Required(ErrorMessage = "La marque du médicament est obligatoire.")] // Validation pour s'assurer que la marque est fournie
    [MinLength(1, ErrorMessage = "La marque du médicament ne peut pas être vide.")] // Validation pour s'assurer que la marque n'est pas une chaîne vide
    [MaxLength(100, ErrorMessage = "La marque du médicament ne doit pas dépasser 100 caractères.")] // Validation pour limiter la longueur de la marque à 100 caractères
    public required string Marque { get; set; } // Marque du médicament, requis entre 1 et 100 caractères

    [Required(ErrorMessage = "Le dosage est obligatoire.")] // Validation pour s'assurer que le dosage est fourni
    [MinLength(1, ErrorMessage = "Le dosage ne peut pas être vide.")] // Validation pour s'assurer que le dosage n'est pas une chaîne vide
    [MaxLength(100, ErrorMessage = "Le dosage ne doit pas dépasser 100 caractères.")] // Validation pour limiter la longueur du dosage à 100 caractères
    public required string Dosage { get; set; } // Dosage du médicament, requis entre 1 et 100 caractères

    [Required(ErrorMessage = "La fréquence est obligatoire.")] // Validation pour s'assurer que la fréquence est fournie
    [MinLength(1, ErrorMessage = "La fréquence ne peut pas être vide.")] // Validation pour s'assurer que la fréquence n'est pas une chaîne vide
    [MaxLength(100, ErrorMessage = "La fréquence ne doit pas dépasser 100 caractères.")] // Validation pour limiter la longueur de la fréquence à 100 caractères
    public required string Frequence { get; set; } // Fréquence d'administration du médicament, requis entre 1 et 100 caractères (ex: "Q4h" ou "6 fois par jour")

    [Range(1, long.MaxValue, ErrorMessage = "AineId doit être un identifiant valide (> 0).")] // Validation pour s'assurer que AineId est un nombre positif
    public long AineId { get; set; } // ID de l'aîné associé au médicament, doit être un nombre positif
}