namespace backend.Endpoints;

// Classe pour les endpoints racine
public static class RootEndpoints
{
    public static void MapRootEndpoints(this WebApplication app) // Methode d'extension pour ajouter les endpoints à l'application
    {
        app.MapGet("/", () => "ProConnectNB API")
            .WithTags("Root")
            .AllowAnonymous()
            .WithOpenApi(o =>
            {
                o.Summary = "API root";
                return o;
            });
    }
}