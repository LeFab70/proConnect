namespace backend.Endpoints;

// Classe pour les endpoints de santé (health check)
public static class HealthEndpoints
{
    public static void MapHealthEndpoints(this WebApplication app) // Methode d'extension pour ajouter les endpoints à l'application
    {
        app.MapGet("/api/health", () => Results.Ok(new { status = "ok" }))
            .WithTags("Health")
            .AllowAnonymous()
            .WithOpenApi(o =>
            {
                o.Summary = "Health check";
                return o;
            });
    }
}