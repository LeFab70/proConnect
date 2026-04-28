// Modèle de base pour les utilisateurs, qui peut être étendu par des classes spécifiques comme Aine et ProcheAidant. Contient les propriétés communes à tous les types d'utilisateurs, telles que le nom, le prénom, le téléphone, l'email et les informations d'authentification.
namespace backend.Models;

public abstract class User
{
    public long Id { get; set; } // Identifiant unique de l'utilisateur, généré automatiquement par la base de données
    // Keycloak (ancien) — gardé en commentaire pour référence
    // public string? KeycloakId { get; set; } // claim "sub"

    public required string Nom { get; set; } // Nom de famille de l'utilisateur, requis pour tous les types d'utilisateurs
    public required string Prenom { get; set; } // Prénom de l'utilisateur, requis pour tous les types d'utilisateurs
    public required string Telephone { get; set; } // Numéro de téléphone de l'utilisateur, requis pour tous les types d'utilisateurs
    public required string Email { get; set; } // Adresse email de l'utilisateur, requise pour tous les types d'utilisateurs
    public Adresse? Adresse { get; set; }

    // Auth locale
    public required string PasswordHash { get; set; } // Hash du mot de passe de l'utilisateur, requis pour tous les types d'utilisateurs utilisant l'authentification locale
    public DateTime? PasswordResetTokenExpiresAtUtc { get; set; } // Date d'expiration du token de réinitialisation de mot de passe, utilisée pour limiter la validité du token et renforcer la sécurité
    public string? PasswordResetTokenHash { get; set; } // Hash du token de réinitialisation de mot de passe, utilisé pour vérifier la validité du token lors de la réinitialisation du mot de passe
}