// Modèle représentant un médicament 
namespace backend.Models;

public class Medicament
{
    public long Id { get; set; } // Identifiant unique du médicament
    public required string Nom { get; set; } // Nom Générique du médicament
    public required string Marque { get; set; } // Marque du médicament
    public required string Dosage { get; set; } // Dosage du médicament
    public required string Frequence { get; set; } // Fréquence d'administration du médicament
    public long AineId { get; set; } // Clé étrangère vers l'aîné auquel est associé ce médicament
}