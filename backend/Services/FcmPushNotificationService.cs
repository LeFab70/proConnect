using System.Text;
using System.Text.Json;
using backend.Infrastructure;
using backend.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace backend.Services;

public class FcmPushNotificationService(AppDbContext db, IHttpClientFactory httpClientFactory) : IPushNotificationService
{
    private readonly AppDbContext _db = db;
    private readonly IHttpClientFactory _http = httpClientFactory;

    public async Task SendToUserAsync(long userId, string title, string body, IDictionary<string, string>? data = null, CancellationToken ct = default)
    {
        await SendToUsersAsync([userId], title, body, data, ct);
    }

    public async Task SendToUsersAsync(IEnumerable<long> userIds, string title, string body, IDictionary<string, string>? data = null, CancellationToken ct = default)
    {
        var serverKey = Environment.GetEnvironmentVariable("FCM__ServerKey");
        if (string.IsNullOrWhiteSpace(serverKey))
        {
            // Push not configured; silently skip.
            return;
        }

        var ids = userIds.Distinct().ToArray();
        if (ids.Length == 0) return;

        var tokens = await _db.DeviceTokens.AsNoTracking()
            .Where(t => t.IsActive && ids.Contains(t.UserId))
            .Select(t => t.Token)
            .Distinct()
            .ToListAsync(ct);

        if (tokens.Count == 0) return;

        var client = _http.CreateClient(nameof(FcmPushNotificationService));

        // Legacy FCM endpoint (works with Server key).
        // For each token, send a message. Keeps payload small and error-isolated.
        foreach (var token in tokens)
        {
            var payload = new Dictionary<string, object?>
            {
                ["to"] = token,
                ["priority"] = "high",
                ["notification"] = new Dictionary<string, string?>
                {
                    ["title"] = title,
                    ["body"] = body
                },
                ["data"] = data ?? new Dictionary<string, string>()
            };

            var json = JsonSerializer.Serialize(payload);
            using var req = new HttpRequestMessage(HttpMethod.Post, "https://fcm.googleapis.com/fcm/send")
            {
                Content = new StringContent(json, Encoding.UTF8, "application/json")
            };
            req.Headers.TryAddWithoutValidation("Authorization", $"key={serverKey}");

            using var resp = await client.SendAsync(req, ct);
            // Do not throw; a single bad token must not break the API call that triggered it.
        }
    }
}

