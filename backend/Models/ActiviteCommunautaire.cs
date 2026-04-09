namespace backend.Models;

// Modèle représentant une activité communautaire dans le système de gestion des activités communautaires
public class ActiviteCommunautaire
{
    public long Id { get; set; } // Identifiant unique de l'activité communautaire
    public required string Titre { get; set; } // Titre de l'activité communautaire
    public required string Description { get; set; } // Description détaillée de l'activité communautaire
    public DateTime DateHeure { get; set; } // Date et heure de l'activité communautaire
    public required string Lieu { get; set; } // Lieu où se déroule l'activité communautaire
    public long CalendrierCommunautaireId { get; set; } // Clé étrangère vers le calendrier communautaire auquel appartient cette activité
}