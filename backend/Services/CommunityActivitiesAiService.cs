using System.Text;
using System.Text.Json;
using backend.Dtos.Activites;
using backend.Services.Interfaces;

namespace backend.Services;

public class CommunityActivitiesAiService : ICommunityActivitiesAiService
{
    private readonly HttpClient _http;
    private static readonly JsonSerializerOptions JsonOpts = new()
    {
        PropertyNameCaseInsensitive = true
    };

    public CommunityActivitiesAiService(HttpClient http)
    {
        _http = http;
        _http.Timeout = TimeSpan.FromSeconds(45);
    }

    public async Task<IReadOnlyList<ActivitySuggestionDto>> Suggest(GetSuggestedActivitiesRequestDto dto, CancellationToken ct = default)
    {
        // NOTE: Par défaut on renvoie du mock pour ne pas dépendre d'une clé/plateforme.

        var provider = (Environment.GetEnvironmentVariable("AI_PROVIDER") ?? "mock").ToLowerInvariant();
        if (provider == "mock")
        {
            return new List<ActivitySuggestionDto>
            {
                new()
                {
                    Titre = "Marche communautaire",
                    Description = $"Activité suggérée près de: {dto.Adresse}. (Suggestion mock)",
                    DateHeure = DateTime.UtcNow.AddDays(3),
                    Lieu = "Parc local",
                    SourceUrl = null
                },
                new()
                {
                    Titre = "Atelier informatique (débutants)",
                    Description = $"Centres d'intérêt: {dto.Interets ?? "N/A"}. (Suggestion mock)",
                    DateHeure = DateTime.UtcNow.AddDays(7),
                    Lieu = "Bibliothèque",
                    SourceUrl = null
                }
            }.Take(dto.Limit).ToList();
        }

        // HuggingFace Inference (gratuit/limité selon compte)
        if (provider == "huggingface")
        {
            var token = Environment.GetEnvironmentVariable("HF_TOKEN");
            var model = Environment.GetEnvironmentVariable("HF_MODEL") ?? "mistralai/Mistral-7B-Instruct-v0.2";
            if (string.IsNullOrWhiteSpace(token))
            {
                throw new InvalidOperationException("Missing env var: HF_TOKEN");
            }

            var prompt = BuildPrompt(dto);

            // Default Serverless Inference endpoint
            var url = Environment.GetEnvironmentVariable("HF_ENDPOINT");
            if (string.IsNullOrWhiteSpace(url))
            {
                url = $"https://api-inference.huggingface.co/models/{model}";
            }

            using var req = new HttpRequestMessage(HttpMethod.Post, url);
            req.Headers.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", token);
            req.Content = new StringContent(JsonSerializer.Serialize(new
            {
                inputs = prompt,
                parameters = new
                {
                    max_new_tokens = 500,
                    return_full_text = false
                }
            }), Encoding.UTF8, "application/json");

            var resp = await _http.SendAsync(req, ct);
            resp.EnsureSuccessStatusCode();

            var raw = await resp.Content.ReadAsStringAsync(ct);

            // HF text-generation responses are often: [ { "generated_text": "..." } ]
            // Some models may return a plain object; handle both.
            var generated = TryExtractGeneratedText(raw) ?? raw;
            var json = TryExtractJsonArray(generated);
            if (json == null)
            {
                throw new InvalidOperationException("AI response did not contain a JSON array of suggestions.");
            }

            var list = JsonSerializer.Deserialize<List<ActivitySuggestionDto>>(json, JsonOpts);
            if (list == null)
            {
                throw new InvalidOperationException("Failed to parse AI suggestions JSON.");
            }

            return list.Take(dto.Limit).ToList();
        }

        throw new InvalidOperationException($"Unsupported AI_PROVIDER: {provider}");
    }

    private static string BuildPrompt(GetSuggestedActivitiesRequestDto dto)
    {
        return $$"""
                 Tu es un assistant qui recommande des activités communautaires pour un aîné.
                 Adresse: {{dto.Adresse}}
                 Intérêts: {{dto.Interets ?? "non spécifiés"}}
                 Donne {{dto.Limit}} suggestions au format JSON strict (IMPORTANT: réponds uniquement avec le JSON, sans texte autour):
                 [
                   { "Titre": "...", "Description": "...", "DateHeure": "2026-01-01T18:00:00Z", "Lieu": "...", "SourceUrl": "..." }
                 ]
                 """;
    }

    private static string? TryExtractGeneratedText(string raw)
    {
        try
        {
            using var doc = JsonDocument.Parse(raw);
            if (doc.RootElement.ValueKind == JsonValueKind.Array && doc.RootElement.GetArrayLength() > 0)
            {
                var first = doc.RootElement[0];
                if (first.ValueKind == JsonValueKind.Object && first.TryGetProperty("generated_text", out var gt))
                {
                    return gt.GetString();
                }
            }
            if (doc.RootElement.ValueKind == JsonValueKind.Object && doc.RootElement.TryGetProperty("generated_text", out var gt2))
            {
                return gt2.GetString();
            }
        }
        catch
        {
            // not JSON
        }
        return null;
    }

    private static string? TryExtractJsonArray(string text)
    {
        var start = text.IndexOf('[');
        var end = text.LastIndexOf(']');
        if (start < 0 || end <= start) return null;
        return text.Substring(start, end - start + 1).Trim();
    }
}

