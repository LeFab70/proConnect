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
using System.Security.Cryptography;

var builder = WebApplication.CreateBuilder(args); // Configuration et services DI (Dependency Injection), variable environnement etc..

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddValidation();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "ProConnectNB API", Version = "v1" });
    c.EnableAnnotations();
    c.MapType<DateOnly>(() => new OpenApiSchema { Type = "string", Format = "date" });
    c.MapType<TimeOnly>(() => new OpenApiSchema { Type = "string", Format = "time" });
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
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IEmailService, EmailService>();
builder.Services.AddHttpClient<ICommunityActivitiesAiService, CommunityActivitiesAiService>();
builder.Services.AddScoped<IAineService, AineService>();
builder.Services.AddScoped<IProcheAidantService, ProcheAidantService>();
builder.Services.AddScoped<IMedicamentService, MedicamentService>();
builder.Services.AddScoped<IRendezVousMedicalService, RendezVousMedicalService>();
builder.Services.AddScoped<IRappelService, RappelService>();
builder.Services.AddScoped<IPartageSuiviService, PartageSuiviService>();
builder.Services.AddScoped<IAzureBlobService, AzureBlobService>();
builder.Services.AddScoped<IImageStorageService, LocalImageStorageService>();
builder.Services.AddScoped<IPushNotificationService, FcmPushNotificationService>();
builder.Services.AddHttpClient(nameof(FcmPushNotificationService));

// EF Core: migrations + runtime (services EF)
builder.Services.AddDbContext<AppDbContext>(options =>
{
    var cs = Environment.GetEnvironmentVariable("DefaultConnection");
    if (!string.IsNullOrWhiteSpace(cs))
    {
        options.UseNpgsql(cs);
    }
});

// Keycloak (ancien) — gardé en commentaire pour référence
// var keycloakAuthority = Environment.GetEnvironmentVariable("KEYCLOAK__AUTHORITY");
// var keycloakAudience = Environment.GetEnvironmentVariable("KEYCLOAK__AUDIENCE");
// builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
//     .AddJwtBearer(options =>
//     {
//         options.Authority = keycloakAuthority;
//         options.Audience = keycloakAudience;
//         options.RequireHttpsMetadata = !builder.Environment.IsDevelopment();
//         options.TokenValidationParameters = new TokenValidationParameters
//         {
//             ValidateIssuer = true,
//             ValidateAudience = true,
//             ValidateLifetime = true,
//             ValidateIssuerSigningKey = true,
//             NameClaimType = "preferred_username"
//         };
//     });

// Auth locale (JWT signé)
var jwtKey = Environment.GetEnvironmentVariable("JWT__Key");
if (string.IsNullOrWhiteSpace(jwtKey))
{
    throw new InvalidOperationException("Missing env var: JWT__Key");
}
// Normalize/derive key bytes so short secrets don't crash token signing/validation.
var jwtKeyBytes = SHA256.HashData(Encoding.UTF8.GetBytes(jwtKey));

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        var issuer = Environment.GetEnvironmentVariable("JWT__Issuer") ?? "ProConnectNB";
        var audience = Environment.GetEnvironmentVariable("JWT__Audience") ?? "ProConnectNB";
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = issuer,
            ValidAudience = audience,
            IssuerSigningKey = new SymmetricSecurityKey(jwtKeyBytes)
        };
    });

builder.Services.AddAuthorization(o =>
{
    o.AddPolicy("AdminOnly", p => p.RequireRole("Admin"));
});

WebApplication app = builder.Build(); // Construction de l'application (apres avoir configurer les services et le builder)

await SeedData.ApplyMigrationsAndSeedAsync(app.Services);

if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}

var enableSwagger = app.Environment.IsDevelopment() ||
                    string.Equals(Environment.GetEnvironmentVariable("ENABLE_SWAGGER"), "true", StringComparison.OrdinalIgnoreCase);

if (enableSwagger)
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Static files for uploaded images
Directory.CreateDirectory(Path.Combine(app.Environment.ContentRootPath, "uploads"));
app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new Microsoft.Extensions.FileProviders.PhysicalFileProvider(
        Path.Combine(app.Environment.ContentRootPath, "uploads")
    ),
    RequestPath = "/uploads"
});

app.UseAuthentication();
app.UseAuthorization();

app.MapRootEndpoints();
app.MapHealthEndpoints();
app.MapAuthEndpoints();
app.MapUsersEndpoints();
app.MapActivitesAiEndpoints();
app.MapAinesEndpoints();
app.MapProchesAidantsEndpoints();
app.MapMedicamentsEndpoints();
app.MapRendezVousMedicauxEndpoints();
app.MapRappelsEndpoints();
app.MapPartagesSuiviEndpoints();
app.MapPushEndpoints();
app.MapImagesEndpoints();

app.Run(); // Demarre l'application et ecoute les requetes HTTP entrantes (roulement continu)