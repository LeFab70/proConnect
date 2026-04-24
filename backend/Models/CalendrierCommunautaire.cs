// Modèle représentant un calendrier communautaire, qui peut être associé à des activités communautaires pour les aînés, avec une propriété region pour identifier le calendrier
namespace backend.Models;

// Modèle représentant un calendrier communautaire
public class CalendrierCommunautaire
{
    public long Id { get; set; } // Identifiant unique du calendrier communautaire
    public required string Region { get; set; } // Région ou zone géographique associée à ce calendrier communautaire (ex: "Gloucester", "Madawaska", "Restigouche" etc.)
}