namespace backend.Endpoints;

public static class HealthEndpoints
{
    public static void MapHealthEndpoints(this WebApplication app)
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