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
  });

  String get time => schedules.isNotEmpty ? schedules.first : '';

  String get schedule => schedules.join(', ');

  String get frequence => schedule;

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
      isTaken: json['isTaken'] == true,
      isActive: json['isActive'] == true || json['IsActive'] == true,
      isDeleted: json['isDeleted'] == true || json['IsDeleted'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': name,
      'marque': marque,
      'dosage': dosage,
      'frequence': schedules.join(', '),
      'aineId': aineId,
      'urlPhoto': urlPhoto,
      'isActive': isActive,
    };
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  @override
  String toString() {
    return 'Medication(name: $name, marque: $marque, dosage: $dosage, schedules: $schedules, urlPhoto: $urlPhoto, active: $isActive)';
  }
}
