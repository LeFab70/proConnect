namespace backend.Dtos.Activites;

/// <summary>
/// Suggestion d'activité (source IA / externe).
/// </summary>
public class ActivitySuggestionDto
{
    /// <summary>Titre de l'activité.</summary>
    public required string Titre { get; set; }
    /// <summary>Description de l'activité.</summary>
    public required string Description { get; set; }
    /// <summary>Date et heure suggérées (optionnel).</summary>
    public DateTime? DateHeure { get; set; }
    /// <summary>Lieu en texte (optionnel).</summary>
    public string? Lieu { get; set; }
    /// <summary>URL de la source (optionnel).</summary>
    public string? SourceUrl { get; set; }
}

