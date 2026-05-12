using backend.Dtos.Auth;

namespace backend.Services.Interfaces;

public interface IAuthService
{
    Task<TokenResponseDto> Register(RegisterRequestDto dto);
    Task<TokenResponseDto?> Login(LoginRequestDto dto);
    Task RequestPasswordReset(ForgotPasswordRequestDto dto);
    Task<bool> ResetPassword(ResetPasswordRequestDto dto);
    Task<bool> ChangePassword(long userId, ChangePasswordRequestDto dto);
}

