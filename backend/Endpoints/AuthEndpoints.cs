using backend.Dtos.Auth;
using backend.Dtos.Users;
using backend.Infrastructure;
using backend.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace backend.Endpoints;

public static class AuthEndpoints
{
    public static void MapAuthEndpoints(this WebApplication app)
    {
        var route = app.MapGroup("/api/auth").WithTags("Auth");

        route.MapPost("/register", Register)
            .AllowAnonymous()
            .Produces<TokenResponseDto>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status400BadRequest)
            .WithSummary("Créer un compte (register)");

        route.MapPost("/login", Login)
            .AllowAnonymous()
            .Produces<TokenResponseDto>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status401Unauthorized)
            .WithSummary("Se connecter (login)");

        route.MapPost("/forgot-password", ForgotPassword)
            .AllowAnonymous()
            .Produces(StatusCodes.Status204NoContent)
            .WithSummary("Demande de reset password (envoie email)");

        route.MapPost("/reset-password", ResetPassword)
            .AllowAnonymous()
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status400BadRequest)
            .WithSummary("Reset password avec token");

        route.MapGet("/me", Me)
            .RequireAuthorization()
            .Produces(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status401Unauthorized)
            .WithSummary("Retourne l'utilisateur courant (JWT)");

        route.MapPost("/change-password", ChangePassword)
            .RequireAuthorization()
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status400BadRequest)
            .WithSummary("Change le mot de passe de l'utilisateur connecté");

        route.MapPut("/profile", UpdateProfile)
            .RequireAuthorization()
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status400BadRequest)
            .WithSummary("Met à jour le prénom et nom de l'utilisateur connecté");
    }

    private static async Task<IResult> Register(RegisterRequestDto dto, IAuthService auth)
    {
        var validation = DtoValidation.Validate(dto);
        if (validation != null) return validation;

        try
        {
            var token = await auth.Register(dto);
            return Results.Ok(token);
        }
        catch (InvalidOperationException ex)
        {
            return Results.BadRequest(new { error = ex.Message });
        }
    }

    private static async Task<IResult> Login(LoginRequestDto dto, IAuthService auth)
    {
        var validation = DtoValidation.Validate(dto);
        if (validation != null) return validation;

        var token = await auth.Login(dto);
        return token == null ? Results.Unauthorized() : Results.Ok(token);
    }

    private static async Task<IResult> ForgotPassword(ForgotPasswordRequestDto dto, IAuthService auth)
    {
        var validation = DtoValidation.Validate(dto);
        if (validation != null) return validation;

        await auth.RequestPasswordReset(dto);
        return Results.NoContent();
    }

    private static async Task<IResult> ResetPassword(ResetPasswordRequestDto dto, IAuthService auth)
    {
        var validation = DtoValidation.Validate(dto);
        if (validation != null) return validation;

        var ok = await auth.ResetPassword(dto);
        return ok ? Results.NoContent() : Results.BadRequest(new { error = "Invalid or expired token" });
    }

    private static async Task<IResult> ChangePassword(ChangePasswordRequestDto dto, ClaimsPrincipal principal, IAuthService auth)
    {
        var validation = DtoValidation.Validate(dto);
        if (validation != null) return validation;

        var idRaw = principal.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!long.TryParse(idRaw, out var userId)) return Results.Unauthorized();

        var ok = await auth.ChangePassword(userId, dto);
        return ok ? Results.NoContent() : Results.BadRequest(new { error = "Mot de passe actuel incorrect." });
    }

    private static IResult Me(ClaimsPrincipal principal)
    {
        var userId = principal.FindFirstValue(ClaimTypes.NameIdentifier);
        var email = principal.FindFirstValue(ClaimTypes.Email);
        var roles = principal.FindAll(ClaimTypes.Role).Select(r => r.Value).ToArray();

        if (string.IsNullOrWhiteSpace(userId)) return Results.Unauthorized();

        return Results.Ok(new
        {
            userId,
            email,
            roles
        });
    }

    private static async Task<IResult> UpdateProfile(UpsertMyProfileRequestDto dto, ClaimsPrincipal principal, AppDbContext db)
    {
        var validation = DtoValidation.Validate(dto);
        if (validation != null) return validation;

        var idRaw = principal.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!long.TryParse(idRaw, out var userId)) return Results.Unauthorized();

        var user = await db.Users.FirstOrDefaultAsync(u => u.Id == userId);
        if (user == null) return Results.NotFound();

        user.Prenom = dto.Prenom.Trim();
        user.Nom = dto.Nom.Trim();
        user.Telephone = dto.Telephone.Trim();
        await db.SaveChangesAsync();

        return Results.NoContent();
    }
}

