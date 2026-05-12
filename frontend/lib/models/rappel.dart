class Rappel {
  final int id;
  final DateTime dateDebut;
  final String heureDebut;
  final int minutesAvantRappel;
  final DateTime dateHeurePrise;
  final DateTime dateHeureNotification;
  final String type;
  final bool actif;
  final int? medicamentId;
  final int? rendezVousMedicalId;
  final String? groupeId;

  Rappel({
    required this.id,
    required this.dateDebut,
    required this.heureDebut,
    required this.minutesAvantRappel,
    required this.dateHeurePrise,
    required this.dateHeureNotification,
    required this.type,
    required this.actif,
    this.medicamentId,
    this.rendezVousMedicalId,
    this.groupeId,
  });

  String get description => type;

  factory Rappel.fromJson(Map<String, dynamic> json) {
    return Rappel(
      id: _parseInt(json['id']),
      dateDebut: _parseDate(json['dateDebut']),
      heureDebut: json['heureDebut']?.toString() ?? '00:00:00',
      minutesAvantRappel: _parseInt(json['minutesAvantRappel']),
      dateHeurePrise: _parseDate(json['dateHeurePrise']),
      dateHeureNotification: _parseDate(json['dateHeureNotification']),
      type: json['type']?.toString() ?? '',
      actif: json['actif'] == true,
      medicamentId: _parseNullableId(
        json['medicamentId'] ?? json['MedicamentId'],
      ),
      rendezVousMedicalId: _parseNullableId(
        json['rendezVousMedicalId'] ?? json['RendezVousMedicalId'],
      ),
      groupeId: json['groupeId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateDebut': _formatDateOnly(dateDebut),
      'heureDebut': heureDebut,
      'minutesAvantRappel': minutesAvantRappel,

      // IMPORTANT :
      // Pas de toUtc(), sinon l'heure peut revenir 3h avant.
      'dateHeurePrise': _formatLocalDateTime(dateHeurePrise),
      'dateHeureNotification': _formatLocalDateTime(dateHeureNotification),

      'type': type,
      'actif': actif,
      'medicamentId': medicamentId,
      'rendezVousMedicalId': rendezVousMedicalId,
      'groupeId': groupeId,
    };
  }

  Rappel copyWith({
    int? id,
    DateTime? dateDebut,
    String? heureDebut,
    int? minutesAvantRappel,
    DateTime? dateHeurePrise,
    DateTime? dateHeureNotification,
    String? type,
    bool? actif,
    int? medicamentId,
    int? rendezVousMedicalId,
    String? groupeId,
  }) {
    return Rappel(
      id: id ?? this.id,
      dateDebut: dateDebut ?? this.dateDebut,
      heureDebut: heureDebut ?? this.heureDebut,
      minutesAvantRappel: minutesAvantRappel ?? this.minutesAvantRappel,
      dateHeurePrise: dateHeurePrise ?? this.dateHeurePrise,
      dateHeureNotification:
          dateHeureNotification ?? this.dateHeureNotification,
      type: type ?? this.type,
      actif: actif ?? this.actif,
      medicamentId: medicamentId ?? this.medicamentId,
      rendezVousMedicalId: rendezVousMedicalId ?? this.rendezVousMedicalId,
      groupeId: groupeId ?? this.groupeId,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value.toString()) ?? 0;
  }

  static int? _parseNullableId(dynamic value) {
    if (value == null) return null;

    final n = _parseInt(value);

    return n == 0 ? null : n;
  }

  static DateTime _parseDate(dynamic value) {
    try {
      if (value == null) return DateTime.now();

      var raw = value.toString().trim();

      // Si backend renvoie seulement une date : 2026-05-12
      if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(raw)) {
        return DateTime.parse(raw);
      }

      // Si backend renvoie 2026-05-12T14:00:00Z,
      // on enlève le Z pour garder 14:00 local.
      if (raw.endsWith('Z')) {
        raw = raw.substring(0, raw.length - 1);
      }

      // Si backend renvoie offset : +00:00, -03:00, etc.
      // on enlève l'offset pour éviter la conversion automatique.
      raw = raw.replaceFirst(RegExp(r'([+-]\d{2}:\d{2})$'), '');

      return DateTime.parse(raw);
    } catch (_) {
      return DateTime.now();
    }
  }

  /// Exposé pour construire UpsertRappelRequestDto en DateOnly ISO.
  static String formatDateOnlyStatic(DateTime date) => _formatDateOnly(date);

  static String _formatDateOnly(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  static String _formatLocalDateTime(DateTime date) {
    final local = DateTime(
      date.year,
      date.month,
      date.day,
      date.hour,
      date.minute,
      date.second,
    );

    return local.toIso8601String();
  }

  @override
  String toString() {
    return 'Rappel(type: $type, heureDebut: $heureDebut, actif: $actif, notification: $dateHeureNotification)';
  }
}
