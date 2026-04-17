namespace backend.Models;

public class Aine : User
{
    public DateOnly DateNaissance { get; set; }
    public required string Adresse { get; set; }
    public string Docteur { get; set; } = string.Empty;
    public string NumeroTelephoneDocteur { get; set; } = string.Empty;
}