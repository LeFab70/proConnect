// Modèle de données pour représenter un proche aidant, qui hérite de la classe User
namespace backend.Models;

public class ProcheAidant : User
{
    // Navigation vers la table de jonction explicite
    public ICollection<PartageSuivi> Partages { get; set; } = new List<PartageSuivi>(); // Ceci permet de représenter la relation plusieurs à plusieurs entre ProcheAidant et Aine à travers la table de jonction PartageSuivi
}