namespace backend.Services.Interfaces;

public interface IPushNotificationService
{
    Task SendToUserAsync(long userId, string title, string body, IDictionary<string, string>? data = null, CancellationToken ct = default);
    Task SendToUsersAsync(IEnumerable<long> userIds, string title, string body, IDictionary<string, string>? data = null, CancellationToken ct = default);
}

