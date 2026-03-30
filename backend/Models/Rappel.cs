namespace backend.Models;

public class Rappel
{
    public long Id { get; set; }
    public DateTime DateHeure { get; set; }
    public required string Type { get; set; } // ex: "Medicament", "RendezVous"
    public bool Actif { get; set; }
    public long? MedicamentId { get; set; }
    public long? RendezVousMedicalId { get; set; }
}

