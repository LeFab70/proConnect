class Medication {
  final String id;
  final String name;
  final String marque;
  final String dosage;
  final List<String> schedules;
  final String? urlPhoto;
  final int aineId;

  final bool isTaken;
  final bool isActive;
  final bool isDeleted;

  // Suivi du médicament
  final DateTime? lastTakenAt;
  final DateTime? missedAt;

  /// "enAttente" | "pris" | "nonPris"
  final String status;

  Medication({
    required this.id,
    required this.name,
    required this.marque,
    required this.dosage,
    required this.schedules,
    this.urlPhoto,
    this.aineId = 0,
    this.isTaken = false,
    this.isActive = false,
    this.isDeleted = false,
    this.lastTakenAt,
    this.missedAt,
    this.status = 'enAttente',
  });

  String get time => schedules.isNotEmpty ? schedules.first : '';

  String get schedule => schedules.join(', ');

  String get frequence => schedule;

  bool get isPending => status == 'enAttente';

  bool get isMissed => status == 'nonPris';

  bool get isConfirmedTaken => status == 'pris';

  Medication copyWith({
    String? id,
    String? name,
    String? marque,
    String? dosage,
    List<String>? schedules,
    String? urlPhoto,
    int? aineId,
    bool? isTaken,
    bool? isActive,
    bool? isDeleted,
    DateTime? lastTakenAt,
    DateTime? missedAt,
    String? status,
    bool clearLastTakenAt = false,
    bool clearMissedAt = false,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      marque: marque ?? this.marque,
      dosage: dosage ?? this.dosage,
      schedules: schedules ?? this.schedules,
      urlPhoto: urlPhoto ?? this.urlPhoto,
      aineId: aineId ?? this.aineId,
      isTaken: isTaken ?? this.isTaken,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      lastTakenAt: clearLastTakenAt ? null : lastTakenAt ?? this.lastTakenAt,
      missedAt: clearMissedAt ? null : missedAt ?? this.missedAt,
      status: status ?? this.status,
    );
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    final rawSchedules =
        json['schedules'] ??
        json['schedule'] ??
        json['frequence'] ??
        json['Frequence'] ??
        json['heure'] ??
        json['time'];

    List<String> parsedSchedules = [];

    if (rawSchedules is List) {
      parsedSchedules = rawSchedules.map((e) => e.toString()).toList();
    } else if (rawSchedules is String && rawSchedules.trim().isNotEmpty) {
      parsedSchedules = rawSchedules
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    parsedSchedules = parsedSchedules.toSet().toList()..sort();

    final isTakenValue = json['isTaken'] == true || json['IsTaken'] == true;

    return Medication(
      id: json['id']?.toString() ?? json['Id']?.toString() ?? '',

      name:
          json['name']?.toString() ??
          json['nom']?.toString() ??
          json['Nom']?.toString() ??
          '',

      marque: json['marque']?.toString() ?? json['Marque']?.toString() ?? '',

      dosage: json['dosage']?.toString() ?? json['Dosage']?.toString() ?? '',

      schedules: parsedSchedules,

      urlPhoto: json['urlPhoto']?.toString() ?? json['UrlPhoto']?.toString(),

      aineId: _parseInt(json['aineId'] ?? json['AineId']),

      isTaken: isTakenValue,

      isActive: json['isActive'] == true || json['IsActive'] == true,

      isDeleted: json['isDeleted'] == true || json['IsDeleted'] == true,

      // IMPORTANT :
      // On garde l'heure locale choisie par l'utilisateur.
      lastTakenAt: _parseLocalDateTime(
        json['lastTakenAt'] ?? json['LastTakenAt'],
      ),

      missedAt: _parseLocalDateTime(json['missedAt'] ?? json['MissedAt']),

      status:
          json['status']?.toString() ??
          json['Status']?.toString() ??
          (isTakenValue ? 'pris' : 'enAttente'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': name,
      'marque': marque,
      'dosage': dosage,
      'frequence': schedules.join(', '),
      'aineId': aineId,
      'urlPhoto': urlPhoto,
      'isTaken': isTaken,
      'isActive': isActive,
      'isDeleted': isDeleted,

      // IMPORTANT :
      // Pas de toUtc() sinon décalage -3h
      'lastTakenAt': lastTakenAt != null
          ? _formatLocalDateTime(lastTakenAt!)
          : null,

      'missedAt': missedAt != null ? _formatLocalDateTime(missedAt!) : null,

      'status': status,
    };
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;

    return int.tryParse(value.toString()) ?? 0;
  }

  static DateTime? _parseLocalDateTime(dynamic value) {
    try {
      if (value == null) return null;

      var raw = value.toString().trim();

      // Retire le Z UTC
      if (raw.endsWith('Z')) {
        raw = raw.substring(0, raw.length - 1);
      }

      // Retire offsets timezone (+00:00, -03:00...)
      raw = raw.replaceFirst(RegExp(r'([+-]\d{2}:\d{2})$'), '');

      return DateTime.parse(raw);
    } catch (_) {
      return null;
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

  @override
  String toString() {
    return 'Medication(id: $id, name: $name, marque: $marque, dosage: $dosage, schedules: $schedules, status: $status, active: $isActive, taken: $isTaken)';
  }
}
