namespace backend.Infrastructure;

public static class RappelScheduling
{
    public static DateTime DateHeurePrise(DateOnly dateDebut, TimeOnly heureDebut) =>
        DateTime.SpecifyKind(dateDebut.ToDateTime(heureDebut), DateTimeKind.Unspecified);

    public static DateTime DateHeureNotification(DateOnly dateDebut, TimeOnly heureDebut, int minutesAvantRappel) =>
        DateHeurePrise(dateDebut, heureDebut).AddMinutes(-minutesAvantRappel);
}
