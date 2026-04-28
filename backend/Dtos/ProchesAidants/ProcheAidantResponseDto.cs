// DTO de réponse pour les proches aidants
using backend.Dtos.Adresse;
using backend.Dtos.Partages;

namespace backend.Dtos.ProchesAidants;

public class ProcheAidantResponseDto
{
    public long Id { get; set; } // Clé primaire
    public required string Nom { get; set; } // Nom du proche aidant
    public required string Prenom { get; set; } // Prénom du proche aidant
    public required string Telephone { get; set; } // Numéro de téléphone du proche aidant
    public required string Email { get; set; } // Adresse e-mail du proche aidant
    public AdresseDto? Adresse { get; set; }
    public IEnumerable<PartageSuiviResponseDto> Partages { get; set; } = Array.Empty<PartageSuiviResponseDto>(); // Liste des partages de suivi associés au proche aidant
}