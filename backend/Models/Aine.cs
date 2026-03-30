namespace backend.Models;

public class Aine
{
    public long Id { get; set; }
    public required string Nom { get; set; }
    public required string Prenom { get; set; }
    public required string Telephone { get; set; }
    public required string Email { get; set; }

    public DateOnly DateNaissance { get; set; }
    public required string Adresse { get; set; }
}

