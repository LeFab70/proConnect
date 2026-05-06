using backend.Services.Interfaces;

namespace backend.Endpoints;

public static class ImagesEndpoints
{
    public static void MapImagesEndpoints(this WebApplication app)
    {
        app.MapPost("/api/images/upload", Upload)
            .RequireAuthorization("AdminOnly")
            .DisableAntiforgery()
            .WithTags("Images")
            .WithSummary("Upload une image vers Azure Blob Storage, retourne { url }");
    }

    private static async Task<IResult> Upload(IFormFile? file, IAzureBlobService blobService)
    {
        if (file == null || file.Length == 0)
            return Results.BadRequest("Aucun fichier reçu.");

        if (!file.ContentType.StartsWith("image/"))
            return Results.BadRequest("Le fichier doit être une image.");

        var url = await blobService.UploadImageAsync(file);
        return Results.Ok(new { url });
    }
}
