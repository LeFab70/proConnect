class Rappel {
  final int id;
  final DateTime dateHeure;
  final String type;
  final bool actif;
  final int? medicamentId;
  final int? rendezVousMedicalId;

  Rappel({
    required this.id,
    required this.dateHeure,
    required this.type,
    required this.actif,
    this.medicamentId,
    this.rendezVousMedicalId,
  });
}