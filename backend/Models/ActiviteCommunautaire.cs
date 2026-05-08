// Modèle représentant une activité communautaire dans le système (Activité créée par les HuggingFace AI pour être partagée dans un calendrier communautaire)
namespace backend.Models;

public class ActiviteCommunautaire
{
    public long Id { get; set; } // Identifiant unique de l'activité communautaire
    public required string Titre { get; set; } // Titre de l'activité communautaire
    public required string Description { get; set; } // Description détaillée de l'activité communautaire
    public DateTime DateHeure { get; set; } // Date et heure de l'activité communautaire
    public required Adresse Lieu { get; set; } // Lieu où se déroule l'activité communautaire (Adresse est une classe qui contient les détails de l'adresse, comme le numéro, la rue, la ville, etc.)
    public long CalendrierCommunautaireId { get; set; } // Clé étrangère vers le calendrier communautaire auquel appartient cette activité
}