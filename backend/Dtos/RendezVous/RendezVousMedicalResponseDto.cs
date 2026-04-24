// DTO pour la réponse de rendez-vous médical, contenant les propriétés nécessaires pour afficher les détails d'un rendez-vous médical, telles que l'identifiant, la date et l'heure, le lieu, le nom du docteur, les notes éventuelles et l'identifiant de l'aîné associé au rendez-vous
using backend.Dtos.Adresse; // Importation du DTO d'adresse pour inclure les détails du lieu du rendez-vous médical

namespace backend.Dtos.RendezVous;

public class RendezVousMedicalResponseDto
{
    public long Id { get; set; } // Identifiant unique du rendez-vous médical
    public DateTime DateHeure { get; set; } // Date et heure du rendez-vous médical
    public AdresseDto Lieu { get; set; } // Lieu du rendez-vous médical
    public required string Docteur { get; set; } // Nom du docteur
    public string? Notes { get; set; } // Notes éventuelles sur le rendez-vous médical
    public long AineId { get; set; } // Identifiant de l'aîné associé au rendez-vous médical
}