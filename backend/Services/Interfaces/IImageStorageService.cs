namespace backend.Services.Interfaces;

public interface IImageStorageService
{
    Task<string> UploadImageAsync(IFormFile file, CancellationToken ct = default);
}

