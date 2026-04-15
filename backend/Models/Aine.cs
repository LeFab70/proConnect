namespace backend.Models;

public class Aine : User
{
    public DateOnly DateNaissance { get; set; }
    public required string Adresse { get; set; }
}