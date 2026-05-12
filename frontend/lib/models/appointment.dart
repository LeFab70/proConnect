class RendezVousMedical {
  final int id;
  final DateTime dateHeure;
  final String lieu;
  final String docteur;
  final String notes;
  final int aineId;

  RendezVousMedical({
    required this.id,
    required this.dateHeure,
    required this.lieu,
    required this.docteur,
    this.notes = '',
    required this.aineId,
  });

  String get titreRappel => 'Rendez-vous médical : Dr $docteur';

  factory RendezVousMedical.fromJson(Map<String, dynamic> json) {
    return RendezVousMedical(
      id: _parseInt(json['id']),
      dateHeure: _parseDate(json['dateHeure']),
      lieu: _parseLieu(json['lieu']),
      docteur: json['docteur']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      aineId: _parseInt(json['aineId']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,

      // IMPORTANT :
      // Ne pas utiliser toUtc(), sinon l'heure choisie revient décalée.
      "dateHeure": _formatLocalDateTime(dateHeure),

      "lieu": lieu,
      "docteur": docteur,
      "notes": notes,
      "aineId": aineId,
    };
  }

  RendezVousMedical copyWith({
    int? id,
    DateTime? dateHeure,
    String? lieu,
    String? docteur,
    String? notes,
    int? aineId,
  }) {
    return RendezVousMedical(
      id: id ?? this.id,
      dateHeure: dateHeure ?? this.dateHeure,
      lieu: lieu ?? this.lieu,
      docteur: docteur ?? this.docteur,
      notes: notes ?? this.notes,
      aineId: aineId ?? this.aineId,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static DateTime _parseDate(dynamic value) {
    try {
      if (value == null) return DateTime.now();

      var raw = value.toString().trim();

      // Si le backend renvoie "2026-05-12T14:00:00Z",
      // on enlève le Z pour garder 14:00 en heure locale.
      if (raw.endsWith('Z')) {
        raw = raw.substring(0, raw.length - 1);
      }

      // Si le backend renvoie un offset comme -03:00 ou +00:00,
      // on enlève l'offset pour garder l'heure choisie.
      raw = raw.replaceFirst(RegExp(r'([+-]\d{2}:\d{2})$'), '');

      return DateTime.parse(raw);
    } catch (_) {
      return DateTime.now();
    }
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

  static String _parseLieu(dynamic value) {
    if (value == null) return '';

    if (value is String) return value;

    if (value is Map<String, dynamic>) {
      final rue = value['rue']?.toString() ?? '';
      final ville = value['ville']?.toString() ?? '';
      final province = value['province']?.toString() ?? '';
      final codePostal = value['codePostal']?.toString() ?? '';

      return [
        rue,
        ville,
        province,
        codePostal,
      ].where((e) => e.trim().isNotEmpty).join(', ');
    }

    return value.toString();
  }

  @override
  String toString() {
    return 'RDV chez $docteur à $lieu le $dateHeure';
  }
}
