namespace backend.Models;

public class RendezVousMedical
{
    public long Id { get; set; }
    public DateTime DateHeure { get; set; }
    public required string Lieu { get; set; }
    public required string Specialiste { get; set; }
    public string? Notes { get; set; }
    public long AineId { get; set; }
}

