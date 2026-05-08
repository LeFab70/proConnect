// Dto de réponse pour une activité communautaire
using backend.Dtos.Adresse; // Importation du DTO pour l'adresse, utilisé pour le lieu de l'activité communautaire (Pour ne pas l'ajouter dans la base de données comme classe séparée, mais plutôt comme une propriété complexe de l'activité communautaire)

namespace backend.Dtos.Activites;

/// <summary>
/// DTO de réponse pour une activité communautaire.
/// </summary>
public class ActiviteCommunautaireResponseDto
{
    /// <summary>Identifiant de l'activité.</summary>
    public long Id { get; set; } // Identifiant de l'activité
    /// <summary>Titre de l'activité.</summary>
    public required string Titre { get; set; } // Titre de l'activité
    /// <summary>Description de l'activité.</summary>
    public required string Description { get; set; } // Description de l'activité
    /// <summary>Date et heure de l'activité.</summary>
    public DateTime DateHeure { get; set; } // Date et heure de l'activité
    /// <summary>Lieu de l'activité.</summary>
    public required AdresseDto Lieu { get; set; } // Lieu de l'activité
    /// <summary>Identifiant du calendrier communautaire.</summary>
    public long CalendrierCommunautaireId { get; set; } // Identifiant du calendrier communautaire
}