using backend.Dtos.Users;
using backend.Infrastructure;
using backend.Services.Interfaces;
using System.Security.Claims;

namespace backend.Endpoints;

public static class UsersEndpoints
{
    public static void MapUsersEndpoints(this WebApplication app)
    {
        var route = app.MapGroup("/api/users").WithTags("Users");

        // read: protected
        route.RequireAuthorization();
        route.MapGet("/me", GetMe)
            .Produces<UserResponseDto>(StatusCodes.Status200OK)
            .WithSummary("Retourne l'utilisateur courant (créé localement si absent)");

        route.MapPut("/me", UpdateMe)
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Met à jour mon profil (Nom/Prénom/Téléphone)");

        route.MapGet("/", GetAll)
            .Produces<IReadOnlyList<UserResponseDto>>(StatusCodes.Status200OK)
            .WithSummary("Récupère tous les utilisateurs");
        route.MapGet("/{id:long}", GetById)
            .Produces<UserResponseDto>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Récupère un utilisateur par id");

        // create: admin only (Keycloak gère les comptes, l'API gère le profil local)
        route.MapPost("/", Create)
            .RequireAuthorization("AdminOnly")
            .Produces(StatusCodes.Status201Created)
            .WithSummary("Crée un utilisateur local (Admin)");

        // write: admin
        route.MapPut("/{id:long}", Update)
            .RequireAuthorization("AdminOnly")
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Met à jour un utilisateur (Admin)");

        route.MapDelete("/{id:long}", Delete)
            .RequireAuthorization("AdminOnly")
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Supprime un utilisateur (Admin)");
    }

    private static async Task<IResult> GetAll(IUserService svc)
    {
        var users = await svc.GetAll();
        return Results.Ok(users);
    }

    private static async Task<IResult> GetMe(ClaimsPrincipal principal, IUserService svc)
    {
        var sub = principal.FindFirstValue(ClaimTypes.NameIdentifier) ?? principal.FindFirstValue("sub");
        if (string.IsNullOrWhiteSpace(sub)) return Results.Unauthorized();

        var email = principal.FindFirstValue(ClaimTypes.Email) ?? principal.FindFirstValue("email") ?? "unknown@local";
        var nom = principal.FindFirstValue("family_name");
        var prenom = principal.FindFirstValue("given_name");

        var me = await svc.GetOrCreateMe(sub, email, nom, prenom);
        return Results.Ok(me);
    }

    private static async Task<IResult> UpdateMe(ClaimsPrincipal principal, UpsertMyProfileRequestDto dto, IUserService svc)
    {
        var validation = DtoValidation.Validate(dto);
        if (validation != null) return validation;

        var sub = principal.FindFirstValue(ClaimTypes.NameIdentifier) ?? principal.FindFirstValue("sub");
        if (string.IsNullOrWhiteSpace(sub)) return Results.Unauthorized();

        var ok = await svc.UpdateMe(sub, dto);
        return ok ? Results.NoContent() : Results.NotFound();
    }

    private static async Task<IResult> GetById(long id, IUserService svc)
    {
        var u = await svc.GetById(id);
        return u == null ? Results.NotFound() : Results.Ok(u);
    }

    private static async Task<IResult> Create(UpsertUserRequestDto dto, IUserService svc)
    {
        var validation = DtoValidation.Validate(dto);
        if (validation != null) return validation;

        var created = await svc.Create(dto);
        return Results.Created($"/api/users/{created.Id}", created);
    }

    private static async Task<IResult> Update(long id, UpsertUserRequestDto dto, IUserService svc)
    {
        var validation = DtoValidation.Validate(dto);
        if (validation != null) return validation;

        var ok = await svc.Update(id, dto);
        return ok ? Results.NoContent() : Results.NotFound();
    }

    private static async Task<IResult> Delete(long id, IUserService svc)
    {
        var ok = await svc.Delete(id);
        return ok ? Results.NoContent() : Results.NotFound();
    }
}

