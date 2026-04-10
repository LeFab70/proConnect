namespace backend.Dtos.Partages;

public class PartageSuiviResponseDto
{
    public long Id { get; set; }
    public required string Autorisation { get; set; }
    public long AineId { get; set; }
    public long ProcheAidantId { get; set; }
}

