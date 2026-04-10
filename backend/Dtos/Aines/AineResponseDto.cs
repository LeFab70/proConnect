namespace backend.Dtos.Aines;

public class AineResponseDto
{
    public long Id { get; set; }
    public required string Nom { get; set; }
    public required string Prenom { get; set; }
    public required string Telephone { get; set; }
    public required string Email { get; set; }
    public DateOnly DateNaissance { get; set; }
    public required string Adresse { get; set; }
    public string Docteur { get; set; }
    public string NumeroTelephoneDocteur { get; set; }
}