using System.ComponentModel.DataAnnotations;

namespace backend.Infrastructure;

public static class DtoValidation
{
    public static IResult? Validate<T>(T dto)
    {
        var context = new ValidationContext(dto!);
        var results = new List<ValidationResult>();
        var ok = Validator.TryValidateObject(dto!, context, results, validateAllProperties: true);
        if (ok) return null;

        var errors = new Dictionary<string, string[]>(StringComparer.OrdinalIgnoreCase);
        foreach (var r in results)
        {
            var members = r.MemberNames?.Any() == true ? r.MemberNames : new[] { string.Empty };
            foreach (var member in members)
            {
                var key = string.IsNullOrWhiteSpace(member) ? "body" : member;
                if (!errors.TryGetValue(key, out var arr))
                {
                    errors[key] = [r.ErrorMessage ?? "Validation error"];
                }
                else
                {
                    errors[key] = arr.Concat([r.ErrorMessage ?? "Validation error"]).ToArray();
                }
            }
        }

        return Results.ValidationProblem(errors);
    }
}

