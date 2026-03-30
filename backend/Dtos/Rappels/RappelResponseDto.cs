namespace backend.Dtos.Rappels;

public class RappelResponseDto
{
    public long Id { get; set; }
    public DateTime DateHeure { get; set; }
    public required string Type { get; set; }
    public bool Actif { get; set; }
    public long? MedicamentId { get; set; }
    public long? RendezVousMedicalId { get; set; }
}

