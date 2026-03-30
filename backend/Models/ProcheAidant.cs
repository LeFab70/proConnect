namespace backend.Models;

public class ProcheAidant
{
    public long Id { get; set; }
    public required string Nom { get; set; }
    public required string Prenom { get; set; }
    public required string Telephone { get; set; }
    public required string Email { get; set; }

    public required string Relation { get; set; }
}

