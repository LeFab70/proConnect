namespace backend.Models;

public class DeviceToken
{
    public long Id { get; set; }
    public long UserId { get; set; }
    public required string Token { get; set; }
    public string? Platform { get; set; } // "android" | "ios"
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
    public DateTime LastSeenAtUtc { get; set; } = DateTime.UtcNow;
}

