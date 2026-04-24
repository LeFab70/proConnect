using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace backend.Migrations
{
    /// <inheritdoc />
    public partial class AutoMigration_202604240513 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "relation",
                table: "users",
                newName: "lieu_ville");

            migrationBuilder.RenameColumn(
                name: "adresse",
                table: "users",
                newName: "lieu_rue");

            migrationBuilder.RenameColumn(
                name: "lieu",
                table: "rendez_vous_medicaux",
                newName: "lieu_ville");

            migrationBuilder.RenameColumn(
                name: "lieu",
                table: "activites_communautaires",
                newName: "lieu_ville");

            migrationBuilder.AddColumn<string>(
                name: "lieu_code_postal",
                table: "users",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "lieu_numero",
                table: "users",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "lieu_province",
                table: "users",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "lieu_code_postal",
                table: "rendez_vous_medicaux",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "lieu_numero",
                table: "rendez_vous_medicaux",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "lieu_province",
                table: "rendez_vous_medicaux",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "lieu_rue",
                table: "rendez_vous_medicaux",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "relation",
                table: "partages_suivi",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "region",
                table: "calendriers_communautaires",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "lieu_code_postal",
                table: "activites_communautaires",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "lieu_numero",
                table: "activites_communautaires",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "lieu_province",
                table: "activites_communautaires",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "lieu_rue",
                table: "activites_communautaires",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.CreateIndex(
                name: "IX_partages_suivi_proche_aidant_id",
                table: "partages_suivi",
                column: "proche_aidant_id");

            migrationBuilder.AddForeignKey(
                name: "FK_partages_suivi_users_proche_aidant_id",
                table: "partages_suivi",
                column: "proche_aidant_id",
                principalTable: "users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_partages_suivi_users_proche_aidant_id",
                table: "partages_suivi");

            migrationBuilder.DropIndex(
                name: "IX_partages_suivi_proche_aidant_id",
                table: "partages_suivi");

            migrationBuilder.DropColumn(
                name: "lieu_code_postal",
                table: "users");

            migrationBuilder.DropColumn(
                name: "lieu_numero",
                table: "users");

            migrationBuilder.DropColumn(
                name: "lieu_province",
                table: "users");

            migrationBuilder.DropColumn(
                name: "lieu_code_postal",
                table: "rendez_vous_medicaux");

            migrationBuilder.DropColumn(
                name: "lieu_numero",
                table: "rendez_vous_medicaux");

            migrationBuilder.DropColumn(
                name: "lieu_province",
                table: "rendez_vous_medicaux");

            migrationBuilder.DropColumn(
                name: "lieu_rue",
                table: "rendez_vous_medicaux");

            migrationBuilder.DropColumn(
                name: "relation",
                table: "partages_suivi");

            migrationBuilder.DropColumn(
                name: "region",
                table: "calendriers_communautaires");

            migrationBuilder.DropColumn(
                name: "lieu_code_postal",
                table: "activites_communautaires");

            migrationBuilder.DropColumn(
                name: "lieu_numero",
                table: "activites_communautaires");

            migrationBuilder.DropColumn(
                name: "lieu_province",
                table: "activites_communautaires");

            migrationBuilder.DropColumn(
                name: "lieu_rue",
                table: "activites_communautaires");

            migrationBuilder.RenameColumn(
                name: "lieu_ville",
                table: "users",
                newName: "relation");

            migrationBuilder.RenameColumn(
                name: "lieu_rue",
                table: "users",
                newName: "adresse");

            migrationBuilder.RenameColumn(
                name: "lieu_ville",
                table: "rendez_vous_medicaux",
                newName: "lieu");

            migrationBuilder.RenameColumn(
                name: "lieu_ville",
                table: "activites_communautaires",
                newName: "lieu");
        }
    }
}
