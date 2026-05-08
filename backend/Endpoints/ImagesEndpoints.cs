using backend.Services.Interfaces;

namespace backend.Endpoints;

public static class ImagesEndpoints
{
    public static void MapImagesEndpoints(this WebApplication app)
    {
        app.MapPost("/api/images/upload", Upload)
            .RequireAuthorization()
            .DisableAntiforgery()
            .WithTags("Images")
            .WithSummary("Upload une image, retourne { urlImage, fileUrl, url }");
    }

    private static async Task<IResult> Upload(HttpRequest request, IFormFile? file, IImageStorageService imageStorageService, CancellationToken ct)
    {
        if (file == null || file.Length == 0)
            return Results.BadRequest("Aucun fichier reçu.");

        if (!file.ContentType.StartsWith("image/"))
            return Results.BadRequest("Le fichier doit être une image.");

        var stored = await imageStorageService.UploadImageAsync(file, ct);

        // If storage returns an absolute URL, keep it. Otherwise build public URL.
        var publicUrl = stored.StartsWith("http://", StringComparison.OrdinalIgnoreCase) ||
                        stored.StartsWith("https://", StringComparison.OrdinalIgnoreCase)
            ? stored
            : $"{request.Scheme}://{request.Host}/uploads/{stored.TrimStart('/')}";

        // Keep backward compatibility: Flutter currently reads "url".
        return Results.Ok(new { urlImage = publicUrl, fileUrl = publicUrl, url = publicUrl });
    }
}
