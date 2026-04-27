using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace backend.Migrations;

/// <inheritdoc />
public partial class MedicamentFlagsAndRappelSchedule : Migration
{
    /// <inheritdoc />
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.AddColumn<bool>(
            name: "is_active",
            table: "medicaments",
            type: "boolean",
            nullable: false,
            defaultValue: true);

        migrationBuilder.AddColumn<bool>(
            name: "is_deleted",
            table: "medicaments",
            type: "boolean",
            nullable: false,
            defaultValue: false);

        migrationBuilder.AddColumn<DateOnly>(
            name: "date_debut",
            table: "rappels",
            type: "date",
            nullable: true);

        migrationBuilder.AddColumn<TimeOnly>(
            name: "heure_debut",
            table: "rappels",
            type: "time without time zone",
            nullable: true);

        migrationBuilder.AddColumn<int>(
            name: "minutes_avant_rappel",
            table: "rappels",
            type: "integer",
            nullable: false,
            defaultValue: 0);

        migrationBuilder.Sql("""
            UPDATE rappels
            SET
              date_debut = (date_heure AT TIME ZONE 'UTC')::date,
              heure_debut = (date_heure AT TIME ZONE 'UTC')::time,
              minutes_avant_rappel = 0
            WHERE date_debut IS NULL;
            """);

        migrationBuilder.AlterColumn<DateOnly>(
            name: "date_debut",
            table: "rappels",
            type: "date",
            nullable: false,
            oldClrType: typeof(DateOnly),
            oldType: "date",
            oldNullable: true);

        migrationBuilder.AlterColumn<TimeOnly>(
            name: "heure_debut",
            table: "rappels",
            type: "time without time zone",
            nullable: false,
            oldClrType: typeof(TimeOnly),
            oldType: "time without time zone",
            oldNullable: true);

        migrationBuilder.DropColumn(
            name: "date_heure",
            table: "rappels");
    }

    /// <inheritdoc />
    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.AddColumn<DateTime>(
            name: "date_heure",
            table: "rappels",
            type: "timestamp with time zone",
            nullable: true);

        migrationBuilder.Sql("""
            UPDATE rappels
            SET date_heure = ((date_debut + heure_debut) AT TIME ZONE 'UTC');
            """);

        migrationBuilder.AlterColumn<DateTime>(
            name: "date_heure",
            table: "rappels",
            type: "timestamp with time zone",
            nullable: false,
            oldClrType: typeof(DateTime),
            oldType: "timestamp with time zone",
            oldNullable: true);

        migrationBuilder.DropColumn(
            name: "date_debut",
            table: "rappels");

        migrationBuilder.DropColumn(
            name: "heure_debut",
            table: "rappels");

        migrationBuilder.DropColumn(
            name: "minutes_avant_rappel",
            table: "rappels");

        migrationBuilder.DropColumn(
            name: "is_active",
            table: "medicaments");

        migrationBuilder.DropColumn(
            name: "is_deleted",
            table: "medicaments");
    }
}
