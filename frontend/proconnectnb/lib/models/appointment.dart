class RendezVousMedical {
  final int id;
  final DateTime dateHeure;
  final String lieu;
  final String docteur;
  final String? notes;
  final int aineId;

  RendezVousMedical({
    required this.id,
    required this.dateHeure,
    required this.lieu,
    required this.docteur,
    this.notes,
    required this.aineId,
  });
}