namespace backend.Services.Interfaces;

public interface IAzureBlobService
{
    Task<string> UploadImageAsync(IFormFile file);
}
