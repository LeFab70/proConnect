using System.Net;
using System.Net.Mail;
using backend.Services.Interfaces;

namespace backend.Services;

public class EmailService : IEmailService
{
    public async Task SendAsync(string toEmail, string subject, string body)
    {
        // SMTP config (optional). If not configured, fallback to console.
        var host = Environment.GetEnvironmentVariable("SMTP__HOST");
        var portStr = Environment.GetEnvironmentVariable("SMTP__PORT");
        var user = Environment.GetEnvironmentVariable("SMTP__USER");
        var pass = Environment.GetEnvironmentVariable("SMTP__PASS");
        var from = Environment.GetEnvironmentVariable("SMTP__FROM") ?? user;

        if (string.IsNullOrWhiteSpace(host) || string.IsNullOrWhiteSpace(portStr) || string.IsNullOrWhiteSpace(from))
        {
            Console.WriteLine("=== EMAIL (fallback console) ===");
            Console.WriteLine($"To: {toEmail}");
            Console.WriteLine($"Subject: {subject}");
            Console.WriteLine(body);
            Console.WriteLine("=== END EMAIL ===");
            await Task.CompletedTask;
            return;
        }

        _ = int.TryParse(portStr, out var port);
        if (port <= 0) port = 587;

        using var client = new SmtpClient(host, port)
        {
            EnableSsl = true
        };
        if (!string.IsNullOrWhiteSpace(user) && !string.IsNullOrWhiteSpace(pass))
        {
            client.Credentials = new NetworkCredential(user, pass);
        }

        using var msg = new MailMessage(from, toEmail, subject, body);
        await client.SendMailAsync(msg);
    }
}

