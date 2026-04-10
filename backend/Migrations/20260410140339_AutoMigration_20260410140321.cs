using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace backend.Migrations
{
    /// <inheritdoc />
    public partial class AutoMigration_20260410140321 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "activites_communautaires",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    titre = table.Column<string>(type: "text", nullable: false),
                    description = table.Column<string>(type: "text", nullable: false),
                    date_heure = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    lieu = table.Column<string>(type: "text", nullable: false),
                    calendrier_communautaire_id = table.Column<long>(type: "bigint", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_activites_communautaires", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "aines",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    nom = table.Column<string>(type: "text", nullable: false),
                    prenom = table.Column<string>(type: "text", nullable: false),
                    telephone = table.Column<string>(type: "text", nullable: false),
                    email = table.Column<string>(type: "text", nullable: false),
                    date_naissance = table.Column<DateOnly>(type: "date", nullable: false),
                    adresse = table.Column<string>(type: "text", nullable: false),
                    docteur = table.Column<string>(type: "text", nullable: false),
                    numero_telephone_docteur = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_aines", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "calendriers_communautaires",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_calendriers_communautaires", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "medicaments",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    nom = table.Column<string>(type: "text", nullable: false),
                    marque = table.Column<string>(type: "text", nullable: false),
                    dosage = table.Column<string>(type: "text", nullable: false),
                    frequence = table.Column<string>(type: "text", nullable: false),
                    aine_id = table.Column<long>(type: "bigint", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_medicaments", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "partages_suivi",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    autorisation = table.Column<string>(type: "text", nullable: false),
                    aine_id = table.Column<long>(type: "bigint", nullable: false),
                    proche_aidant_id = table.Column<long>(type: "bigint", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_partages_suivi", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "proches_aidants",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    nom = table.Column<string>(type: "text", nullable: false),
                    prenom = table.Column<string>(type: "text", nullable: false),
                    telephone = table.Column<string>(type: "text", nullable: false),
                    email = table.Column<string>(type: "text", nullable: false),
                    relation = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_proches_aidants", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "rappels",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    date_heure = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    type = table.Column<string>(type: "text", nullable: false),
                    actif = table.Column<bool>(type: "boolean", nullable: false),
                    medicament_id = table.Column<long>(type: "bigint", nullable: true),
                    rendez_vous_medical_id = table.Column<long>(type: "bigint", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_rappels", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "rendez_vous_medicaux",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    date_heure = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    lieu = table.Column<string>(type: "text", nullable: false),
                    docteur = table.Column<string>(type: "text", nullable: false),
                    notes = table.Column<string>(type: "text", nullable: true),
                    aine_id = table.Column<long>(type: "bigint", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_rendez_vous_medicaux", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "users",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    nom = table.Column<string>(type: "text", nullable: false),
                    prenom = table.Column<string>(type: "text", nullable: false),
                    telephone = table.Column<string>(type: "text", nullable: false),
                    email = table.Column<string>(type: "text", nullable: false),
                    role = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_users", x => x.Id);
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "activites_communautaires");

            migrationBuilder.DropTable(
                name: "aines");

            migrationBuilder.DropTable(
                name: "calendriers_communautaires");

            migrationBuilder.DropTable(
                name: "medicaments");

            migrationBuilder.DropTable(
                name: "partages_suivi");

            migrationBuilder.DropTable(
                name: "proches_aidants");

            migrationBuilder.DropTable(
                name: "rappels");

            migrationBuilder.DropTable(
                name: "rendez_vous_medicaux");

            migrationBuilder.DropTable(
                name: "users");
        }
    }
}
