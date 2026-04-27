using backend.Dtos.Rappels;

namespace backend.Infrastructure;

public static class RappelRequestValidation
{
    public const string TypeMedicament = "Medicament";
    public const string TypeRendezVousMedical = "RendezVousMedical";

    public static string? GetError(UpsertRappelRequestDto dto)
    {
        if (dto.DateDebut == default)
            return "DateDebut est obligatoire.";
        if (dto.MinutesAvantRappel < 0 || dto.MinutesAvantRappel > 10080)
            return "MinutesAvantRappel doit être entre 0 et 10080 (7 jours).";

        var t = dto.Type.Trim();
        if (t.Equals(TypeMedicament, StringComparison.OrdinalIgnoreCase))
        {
            if (dto.MedicamentId is null or <= 0)
                return "MedicamentId est requis pour un rappel de type Medicament.";
            if (dto.RendezVousMedicalId != null)
                return "RendezVousMedicalId doit être vide pour un rappel lié à un médicament.";
            return null;
        }

        if (t.Equals(TypeRendezVousMedical, StringComparison.OrdinalIgnoreCase))
        {
            if (dto.RendezVousMedicalId is null or <= 0)
                return "RendezVousMedicalId est requis pour un rappel de type RendezVousMedical.";
            if (dto.MedicamentId != null)
                return "MedicamentId doit être vide pour un rappel lié à un rendez-vous médical.";
            return null;
        }

        return $"Type inconnu « {dto.Type} » : utiliser {TypeMedicament} ou {TypeRendezVousMedical}.";
    }
}
