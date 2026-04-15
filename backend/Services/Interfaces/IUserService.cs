using backend.Dtos.Common;
using backend.Dtos.Users;

namespace backend.Services.Interfaces;

public interface IUserService
{
    Task<IReadOnlyList<UserResponseDto>> GetAll();
    Task<UserResponseDto?> GetById(long id);
    Task<UserResponseDto> GetOrCreateMe(string keycloakId, string email, string? nom, string? prenom);
    Task<bool> UpdateMe(string keycloakId, UpsertMyProfileRequestDto dto);
    Task<IdResponseDto> Create(UpsertUserRequestDto dto);
    Task<bool> Update(long id, UpsertUserRequestDto dto);
    Task<bool> Delete(long id);
}

