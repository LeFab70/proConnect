using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using backend.Dtos.Auth;
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

var jwtKey = Environment.GetEnvironmentVariable("JWT__Key");
if (string.IsNullOrWhiteSpace(jwtKey))
{
    Console.WriteLine("WARNING: Missing JWT__Key. Using dummy key.");
    jwtKey = "THIS_IS_A_DEV_FALLBACK_KEY_1234567890";
}

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
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey))
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
app.MapAuthEndpoints();
app.MapUsersEndpoints();
app.MapAinesEndpoints();
app.MapProchesAidantsEndpoints();
app.MapMedicamentsEndpoints();
app.MapRendezVousMedicauxEndpoints();
app.MapRappelsEndpoints();
app.MapPartagesSuiviEndpoints();

app.Run(); // Demarre l'application et ecoute les requetes HTTP entrantes (roulement continu)