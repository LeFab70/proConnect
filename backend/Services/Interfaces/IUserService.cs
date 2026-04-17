using backend.Dtos.Common;
using backend.Dtos.Users;

namespace backend.Services.Interfaces;

public interface IUserService
{
    Task<IReadOnlyList<UserResponseDto>> GetAll();
    Task<UserResponseDto?> GetById(long id);
    Task<IdResponseDto> Create(UpsertUserRequestDto dto);
    Task<bool> Update(long id, UpsertUserRequestDto dto);
    Task<bool> Delete(long id);
}

