namespace backend.Models;

public abstract class User
{
    public long Id { get; set; }
    public required string KeycloakId { get; set; } // Keycloak "sub"
    public required string Nom { get; set; }
    public required string Prenom { get; set; }
    public required string Telephone { get; set; }
    public required string Email { get; set; }
    // Les rôles/autorisations viennent de Keycloak (claims JWT)
}