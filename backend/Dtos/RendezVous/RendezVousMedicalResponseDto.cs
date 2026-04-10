namespace backend.Dtos.RendezVous;

public class RendezVousMedicalResponseDto
{
    public long Id { get; set; }
    public DateTime DateHeure { get; set; }
    public required string Lieu { get; set; }
    public required string Docteur { get; set; }
    public string? Notes { get; set; }
    public long AineId { get; set; }
}

