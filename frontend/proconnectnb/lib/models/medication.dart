class Medication {
  final String id;
  final String name;
  final String dosage;
  final String schedule;
  bool isTaken;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.schedule,
    this.isTaken = false,
  });

  Medication copyWith({
    String? id,
    String? name,
    String? dosage,
    String? schedule,
    bool? isTaken,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      schedule: schedule ?? this.schedule,
      isTaken: isTaken ?? this.isTaken,
    );
  }
}
