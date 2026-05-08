// Modèle de données pour une adresse (Classe utilisée pour représenter une adresse dans le système de gestion des activités communautaires)
namespace backend.Models;

public class Adresse
{
    public required string Numero { get; set; } // Numéro de rue de l'adresse
    public required string Rue { get; set; } // Rue de l'adresse
    public required string Ville { get; set; } // Ville de l'adresse
    public required string CodePostal { get; set; } // Code postal de l'adresse
    public required string Province { get; set; } // Province de l'adresse
}