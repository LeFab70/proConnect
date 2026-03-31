namespace backend.Endpoints;

public static class RootEndpoints
{
    public static void MapRootEndpoints(this WebApplication app)
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

