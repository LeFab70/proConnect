using backend.Dtos.Auth;
using backend.Infrastructure;
using backend.Services.Interfaces;
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
}

