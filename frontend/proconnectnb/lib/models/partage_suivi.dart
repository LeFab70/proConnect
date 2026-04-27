class PartageSuivi {
  final int id;
  final String autorisation;
  final int aineId;
  final int procheAidantId;

  PartageSuivi({
    required this.id,
    required this.autorisation,
    required this.aineId,
    required this.procheAidantId,
  });

  factory PartageSuivi.fromJson(Map<String, dynamic> json) {
    return PartageSuivi(
      id: json['id'],
      autorisation: json['autorisation'],
      aineId: json['aineId'],
      procheAidantId: json['procheAidantId'],
    );
  }

  // Convertit l'objet Dart en JSON pour l'envoi (UpsertRequest)
  Map<String, dynamic> toJson() {
    return {
      'autorisation': autorisation,
      'aineId': aineId,
      'procheAidantId': procheAidantId,
    };
  }
}