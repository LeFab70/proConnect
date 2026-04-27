namespace backend.Dtos.Rappels;

public class RappelResponseDto
{
    public long Id { get; set; }
    public DateOnly DateDebut { get; set; }
    public TimeOnly HeureDebut { get; set; }
    public int MinutesAvantRappel { get; set; }
    public DateTime DateHeurePrise { get; set; }
    public DateTime DateHeureNotification { get; set; }
    public required string Type { get; set; }
    public bool Actif { get; set; }
    public long? MedicamentId { get; set; }
    public long? RendezVousMedicalId { get; set; }
}
