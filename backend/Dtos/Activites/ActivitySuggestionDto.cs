namespace backend.Dtos.Activites;

public class ActivitySuggestionDto
{
    public required string Titre { get; set; }
    public required string Description { get; set; }
    public DateTime? DateHeure { get; set; }
    public string? Lieu { get; set; }
    public string? SourceUrl { get; set; }
}

