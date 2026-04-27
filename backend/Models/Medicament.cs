namespace backend.Models;

public class Medicament
{
    public long Id { get; set; }
    public required string Nom { get; set; }
    public required string Marque { get; set; }
    public required string Dosage { get; set; }
    public required string Frequence { get; set; }
    public long AineId { get; set; }
    public bool IsActive { get; set; } = true;
    public bool IsDeleted { get; set; }
}