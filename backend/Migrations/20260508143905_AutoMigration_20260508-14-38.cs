using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace backend.Migrations
{
    /// <inheritdoc />
    public partial class AutoMigration_202605081438 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_partages_suivi_users_proche_aidant_id",
                table: "partages_suivi");

            migrationBuilder.AlterColumn<long>(
                name: "proche_aidant_id",
                table: "partages_suivi",
                type: "bigint",
                nullable: true,
                oldClrType: typeof(long),
                oldType: "bigint");

            migrationBuilder.AddColumn<DateTime>(
                name: "created_at_utc",
                table: "partages_suivi",
                type: "timestamp with time zone",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<string>(
                name: "proche_email",
                table: "partages_suivi",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "statut",
                table: "partages_suivi",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddForeignKey(
                name: "FK_partages_suivi_users_proche_aidant_id",
                table: "partages_suivi",
                column: "proche_aidant_id",
                principalTable: "users",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_partages_suivi_users_proche_aidant_id",
                table: "partages_suivi");

            migrationBuilder.DropColumn(
                name: "created_at_utc",
                table: "partages_suivi");

            migrationBuilder.DropColumn(
                name: "proche_email",
                table: "partages_suivi");

            migrationBuilder.DropColumn(
                name: "statut",
                table: "partages_suivi");

            migrationBuilder.AlterColumn<long>(
                name: "proche_aidant_id",
                table: "partages_suivi",
                type: "bigint",
                nullable: false,
                defaultValue: 0L,
                oldClrType: typeof(long),
                oldType: "bigint",
                oldNullable: true);

            migrationBuilder.AddForeignKey(
                name: "FK_partages_suivi_users_proche_aidant_id",
                table: "partages_suivi",
                column: "proche_aidant_id",
                principalTable: "users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
