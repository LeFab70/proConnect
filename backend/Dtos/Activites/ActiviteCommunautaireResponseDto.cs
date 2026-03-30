namespace backend.Dtos.Activites;

public class ActiviteCommunautaireResponseDto
{
    public long Id { get; set; }
    public required string Titre { get; set; }
    public required string Description { get; set; }
    public DateTime DateHeure { get; set; }
    public required string Lieu { get; set; }
    public long CalendrierCommunautaireId { get; set; }
}

