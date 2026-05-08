using backend.Services.Interfaces;
using Microsoft.AspNetCore.StaticFiles;

namespace backend.Services;

public class LocalImageStorageService : IImageStorageService
{
    private readonly IWebHostEnvironment _env;

    public LocalImageStorageService(IWebHostEnvironment env)
    {
        _env = env;
    }

    public async Task<string> UploadImageAsync(IFormFile file, CancellationToken ct = default)
    {
        var uploadsDir = Path.Combine(_env.ContentRootPath, "uploads");
        Directory.CreateDirectory(uploadsDir);

        var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
        if (string.IsNullOrWhiteSpace(extension))
            extension = GuessExtensionFromContentType(file.ContentType) ?? ".jpg";

        var fileName = $"{Guid.NewGuid():N}{extension}";
        var fullPath = Path.Combine(uploadsDir, fileName);

        await using var stream = File.Create(fullPath);
        await file.CopyToAsync(stream, ct);

        // We return a relative path; endpoint will build the public URL.
        return fileName;
    }

    private static string? GuessExtensionFromContentType(string? contentType)
    {
        if (string.IsNullOrWhiteSpace(contentType)) return null;

        // Quick mapping; keep conservative.
        return contentType.ToLowerInvariant() switch
        {
            "image/jpeg" => ".jpg",
            "image/jpg" => ".jpg",
            "image/png" => ".png",
            "image/webp" => ".webp",
            "image/gif" => ".gif",
            _ => null
        };
    }
}

