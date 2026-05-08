using backend.Dtos.Users;
using backend.Infrastructure;
using backend.Services.Interfaces;

namespace backend.Endpoints;

public static class UsersEndpoints
{
    public static void MapUsersEndpoints(this WebApplication app)
    {
        var route = app.MapGroup("/api/users").WithTags("Users");

        route.RequireAuthorization();

        route.MapGet("/", GetAll)
            .Produces<IReadOnlyList<UserResponseDto>>(StatusCodes.Status200OK)
            .WithSummary("Récupère tous les utilisateurs");
        route.MapGet("/{id:long}", GetById)
            .Produces<UserResponseDto>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Récupère un utilisateur par id");

        route.MapPost("/", Create)
            .Produces(StatusCodes.Status201Created)
            .WithSummary("Crée un utilisateur local");

        route.MapPut("/{id:long}", Update)
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Met à jour un utilisateur");

        route.MapDelete("/{id:long}", Delete)
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status404NotFound)
            .WithSummary("Supprime un utilisateur");
    }

    private static async Task<IResult> GetAll(IUserService svc)
    {
        var users = await svc.GetAll();
        return Results.Ok(users);
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