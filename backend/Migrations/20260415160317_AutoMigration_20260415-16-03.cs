using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace backend.Migrations
{
    /// <inheritdoc />
    public partial class AutoMigration_202604151603 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "aines");

            migrationBuilder.DropTable(
                name: "proches_aidants");

            migrationBuilder.RenameColumn(
                name: "role",
                table: "users",
                newName: "relation");

            migrationBuilder.AddColumn<string>(
                name: "adresse",
                table: "users",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<DateOnly>(
                name: "date_naissance",
                table: "users",
                type: "date",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "docteur",
                table: "users",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "keycloak_id",
                table: "users",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "numero_telephone_docteur",
                table: "users",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "type",
                table: "users",
                type: "character varying(13)",
                maxLength: 13,
                nullable: false,
                defaultValue: "");

            migrationBuilder.CreateIndex(
                name: "IX_users_keycloak_id",
                table: "users",
                column: "keycloak_id",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_users_keycloak_id",
                table: "users");

            migrationBuilder.DropColumn(
                name: "adresse",
                table: "users");

            migrationBuilder.DropColumn(
                name: "date_naissance",
                table: "users");

            migrationBuilder.DropColumn(
                name: "docteur",
                table: "users");

            migrationBuilder.DropColumn(
                name: "keycloak_id",
                table: "users");

            migrationBuilder.DropColumn(
                name: "numero_telephone_docteur",
                table: "users");

            migrationBuilder.DropColumn(
                name: "type",
                table: "users");

            migrationBuilder.RenameColumn(
                name: "relation",
                table: "users",
                newName: "role");

            migrationBuilder.CreateTable(
                name: "aines",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    adresse = table.Column<string>(type: "text", nullable: false),
                    date_naissance = table.Column<DateOnly>(type: "date", nullable: false),
                    docteur = table.Column<string>(type: "text", nullable: false),
                    email = table.Column<string>(type: "text", nullable: false),
                    nom = table.Column<string>(type: "text", nullable: false),
                    numero_telephone_docteur = table.Column<string>(type: "text", nullable: false),
                    prenom = table.Column<string>(type: "text", nullable: false),
                    telephone = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_aines", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "proches_aidants",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    email = table.Column<string>(type: "text", nullable: false),
                    nom = table.Column<string>(type: "text", nullable: false),
                    prenom = table.Column<string>(type: "text", nullable: false),
                    relation = table.Column<string>(type: "text", nullable: false),
                    telephone = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_proches_aidants", x => x.Id);
                });
        }
    }
}
