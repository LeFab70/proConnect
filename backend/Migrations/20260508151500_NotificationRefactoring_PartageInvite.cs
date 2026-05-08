using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace backend.Migrations;

public partial class NotificationRefactoring_PartageInvite : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.AlterColumn<long>(
            name: "proche_aidant_id",
            table: "partages_suivi",
            type: "bigint",
            nullable: true,
            oldClrType: typeof(long),
            oldType: "bigint");

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
            defaultValue: "enAttente");

        migrationBuilder.AddColumn<DateTime>(
            name: "created_at_utc",
            table: "partages_suivi",
            type: "timestamp with time zone",
            nullable: false,
            defaultValueSql: "NOW()");
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropColumn(name: "created_at_utc", table: "partages_suivi");
        migrationBuilder.DropColumn(name: "statut", table: "partages_suivi");
        migrationBuilder.DropColumn(name: "proche_email", table: "partages_suivi");

        migrationBuilder.AlterColumn<long>(
            name: "proche_aidant_id",
            table: "partages_suivi",
            type: "bigint",
            nullable: false,
            oldClrType: typeof(long),
            oldType: "bigint",
            oldNullable: true);
    }
}

