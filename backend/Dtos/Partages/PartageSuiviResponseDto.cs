namespace backend.Dtos.Partages;

public class PartageSuiviResponseDto
{
    public long Id { get; set; }
    public required string Autorisation { get; set; }
    public required string Relation { get; set; }
    public long AineId { get; set; }
    public string? AineNom { get; set; }
    public string? AinePrenom { get; set; }
    public long? ProcheAidantId { get; set; }
    public string? ProcheNom { get; set; }
    public string? ProchePrenom { get; set; }
    public string? ProcheEmail { get; set; }
    public required string Statut { get; set; }
    public DateTime CreatedAtUtc { get; set; }
}