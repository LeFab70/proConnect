using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using backend.Services.Interfaces;

namespace backend.Services;

public class AzureBlobService : IAzureBlobService
{
    private readonly string _connectionString;
    private readonly string _containerName;

    public AzureBlobService()
    {
        _connectionString = Environment.GetEnvironmentVariable("AZURE_STORAGE_CONNECTION_STRING")
            ?? throw new InvalidOperationException("Missing env var: AZURE_STORAGE_CONNECTION_STRING");
        _containerName = Environment.GetEnvironmentVariable("AZURE_STORAGE_CONTAINER") ?? "medicaments";
    }

    public async Task<string> UploadImageAsync(IFormFile file)
    {
        var container = new BlobContainerClient(_connectionString, _containerName);
        await container.CreateIfNotExistsAsync(PublicAccessType.Blob);

        var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
        if (string.IsNullOrWhiteSpace(extension)) extension = ".jpg";

        var blobName = $"{Guid.NewGuid()}{extension}";
        var blobClient = container.GetBlobClient(blobName);

        var headers = new BlobHttpHeaders { ContentType = file.ContentType };
        await blobClient.UploadAsync(file.OpenReadStream(), headers);

        return blobClient.Uri.ToString();
    }
}
