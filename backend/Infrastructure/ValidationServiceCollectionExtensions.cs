using Microsoft.Extensions.DependencyInjection;

namespace backend.Infrastructure;

public static class ValidationServiceCollectionExtensions
{
    // Architecture en couches: garder un point d'entrée clair pour "validation"
    public static IServiceCollection AddValidation(this IServiceCollection services)
    {
        services.AddProblemDetails();
        return services;
    }
}

