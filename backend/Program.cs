using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using backend.Endpoints;
using backend.Infrastructure;
using backend.Services;
using backend.Services.Interfaces;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using System.Reflection;

var builder = WebApplication.CreateBuilder(args); // Configuration et services DI (Dependency Injection), variable environnement etc..

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddValidation();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "ProConnectNB API", Version = "v1" });
    c.EnableAnnotations();
    var xmlName = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
    var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlName);
    if (File.Exists(xmlPath))
    {
        c.IncludeXmlComments(xmlPath);
    }
    var securityScheme = new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Description = "JWT Authorization header using the Bearer scheme. Example: \"Bearer {token}\"",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" }
    };
    c.AddSecurityDefinition("Bearer", securityScheme);
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        { securityScheme, Array.Empty<string>() }
    });
});

builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IAineService, AineService>();
builder.Services.AddScoped<IProcheAidantService, ProcheAidantService>();
builder.Services.AddScoped<IMedicamentService, MedicamentService>();
builder.Services.AddScoped<IRendezVousMedicalService, RendezVousMedicalService>();
builder.Services.AddScoped<IRappelService, RappelService>();
builder.Services.AddScoped<IPartageSuiviService, PartageSuiviService>();

// EF Core: migrations + runtime (services EF)
builder.Services.AddDbContext<AppDbContext>(options =>
{
    var cs = Environment.GetEnvironmentVariable("DefaultConnection");
    if (!string.IsNullOrWhiteSpace(cs))
    {
        options.UseNpgsql(cs);
    }
});

var keycloakAuthority = Environment.GetEnvironmentVariable("KEYCLOAK__AUTHORITY");
var keycloakAudience = Environment.GetEnvironmentVariable("KEYCLOAK__AUDIENCE");
if (string.IsNullOrWhiteSpace(keycloakAuthority) || string.IsNullOrWhiteSpace(keycloakAudience))
{
    throw new InvalidOperationException("Missing env vars: KEYCLOAK__AUTHORITY and/or KEYCLOAK__AUDIENCE.");
}

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.Authority = keycloakAuthority;
        options.Audience = keycloakAudience;
        options.RequireHttpsMetadata = !builder.Environment.IsDevelopment();
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            NameClaimType = "preferred_username"
        };

        // Keycloak: mapper realm_access.roles -> ClaimTypes.Role
        options.Events = new JwtBearerEvents
        {
            OnTokenValidated = context =>
            {
                var identity = context.Principal?.Identity as ClaimsIdentity;
                var realmAccess = context.Principal?.FindFirst("realm_access")?.Value;
                if (identity != null && !string.IsNullOrWhiteSpace(realmAccess))
                {
                    try
                    {
                        using var doc = System.Text.Json.JsonDocument.Parse(realmAccess);
                        if (doc.RootElement.TryGetProperty("roles", out var roles) && roles.ValueKind == System.Text.Json.JsonValueKind.Array)
                        {
                            foreach (var r in roles.EnumerateArray())
                            {
                                var role = r.GetString();
                                if (!string.IsNullOrWhiteSpace(role))
                                {
                                    identity.AddClaim(new Claim(ClaimTypes.Role, role));
                                }
                            }
                        }
                    }
                    catch
                    {
                        // ignore malformed realm_access
                    }
                }
                return Task.CompletedTask;
            }
        };
    });

builder.Services.AddAuthorization(o =>
{
    o.AddPolicy("AdminOnly", p => p.RequireRole("Admin"));
});

WebApplication app = builder.Build(); // Construction de l'application (apres avoir configurer les services et le builder)

await SeedData.ApplyMigrationsAndSeedAsync(app.Services);

// TODO: Enlever les commentaires si on veut utiliser l'API Key
// Middleware pour la gestion de l'API Key (regarder si on a la bonne clef dans les headers)
/*
app.Use(async (context, next) =>
{
    var config = context.RequestServices.GetRequiredService<IConfiguration>();
    var apiKey = config["ApiKey"];

    if (!context.Request.Headers.TryGetValue("x-api-key", out var providedKey))
    {
        context.Response.StatusCode = 401;
        await context.Response.WriteAsync("Missing API Key");
        return;
    }

    if (providedKey != apiKey)
    {
        context.Response.StatusCode = 403;
        await context.Response.WriteAsync("Invalid API Key");
        return;
    }

    await next();
});
*/

if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseAuthentication();
app.UseAuthorization();

app.MapRootEndpoints();
app.MapHealthEndpoints();
app.MapUsersEndpoints();
app.MapAinesEndpoints();
app.MapProchesAidantsEndpoints();
app.MapMedicamentsEndpoints();
app.MapRendezVousMedicauxEndpoints();
app.MapRappelsEndpoints();
app.MapPartagesSuiviEndpoints();

app.Run(); // Demarre l'application et ecoute les requetes HTTP entrantes (roulement continu)