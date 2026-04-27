namespace backend.Models;

public class Rappel
{
    public long Id { get; set; }
    public DateOnly DateDebut { get; set; }
    public TimeOnly HeureDebut { get; set; }
    public int MinutesAvantRappel { get; set; }
    public required string Type { get; set; }
    public bool Actif { get; set; }
    public long? MedicamentId { get; set; }
    public long? RendezVousMedicalId { get; set; }
}