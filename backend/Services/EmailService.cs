using System.Net;
using System.Net.Mail;
using backend.Services.Interfaces;

namespace backend.Services;

public class EmailService(ILogger<EmailService> logger) : IEmailService
{
    public async Task SendAsync(string toEmail, string subject, string body)
    {
        var host = Environment.GetEnvironmentVariable("SMTP__HOST");
        var portStr = Environment.GetEnvironmentVariable("SMTP__PORT");
        var user = Environment.GetEnvironmentVariable("SMTP__USER");
        var pass = Environment.GetEnvironmentVariable("SMTP__PASS");
        var from = Environment.GetEnvironmentVariable("SMTP__FROM") ?? user;

        if (string.IsNullOrWhiteSpace(host) || string.IsNullOrWhiteSpace(portStr) || string.IsNullOrWhiteSpace(from))
        {
            logger.LogInformation("EMAIL (SMTP non configuré) — To: {To} | Subject: {Subject}", toEmail, subject);
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

