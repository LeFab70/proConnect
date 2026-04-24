// DTO de réponse pour les médicaments
namespace backend.Dtos.Medicaments;

public class MedicamentResponseDto
{
    public long Id { get; set; } // ID du médicament
    public required string Nom { get; set; } // Nom du médicament
    public required string Marque { get; set; } // Marque du médicament
    public required string Dosage { get; set; } // Dosage du médicament
    public required string Frequence { get; set; } // Fréquence d'administration du médicament
    public long AineId { get; set; } // ID de l'aîné associé au médicament
}