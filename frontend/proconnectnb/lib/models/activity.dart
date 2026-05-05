class ActiviteIA {
  final int id;
  final String titre;
  final String description;
  final DateTime dateHeure;
  final String lieu;
  final String categorie;
  final double scorePertinence;
  final String region;

  ActiviteIA({
    required this.id,
    required this.titre,
    required this.description,
    required this.dateHeure,
    required this.lieu,
    required this.categorie,
    this.scorePertinence = 1.0,
    required this.region,
  });

  factory ActiviteIA.fromJson(Map<String, dynamic> json) {
    final location = json['location'];

    String lieu = 'Lieu non spécifié';
    if (json['lieu'] != null) {
      lieu = json['lieu'].toString();
    } else if (json['place_hierarchies'] != null) {
      lieu = json['place_hierarchies'].toString();
    } else if (location is List && location.length >= 2) {
      lieu = "${location[1]}, ${location[0]}";
    } else if (location != null) {
      lieu = location.toString();
    }

    return ActiviteIA(
      id: _parseInt(json['id'] ?? json['rank']),
      titre:
          json['titre']?.toString() ?? json['title']?.toString() ?? 'Activité',
      description: json['description']?.toString() ?? '',
      dateHeure: _parseDate(json['dateHeure'] ?? json['start']),
      lieu: lieu,
      categorie:
          json['categorie']?.toString() ??
          json['category']?.toString() ??
          'Général',
      scorePertinence: _parseDouble(
        json['score_pertinence'] ?? json['rank'] ?? json['local_rank'],
      ),
      region:
          json['region']?.toString() ??
          json['country']?.toString() ??
          'Inconnue',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'dateHeure': dateHeure.toIso8601String(),
      'lieu': lieu,
      'categorie': categorie,
      'score_pertinence': scorePertinence,
      'region': region,
    };
  }

  static int _parseInt(dynamic value) {
    if (value == null) return DateTime.now().millisecondsSinceEpoch;
    if (value is int) return value;
    return int.tryParse(value.toString()) ??
        DateTime.now().millisecondsSinceEpoch;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 1.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 1.0;
  }

  static DateTime _parseDate(dynamic value) {
    try {
      if (value == null) return DateTime.now();
      return DateTime.parse(value.toString());
    } catch (_) {
      return DateTime.now();
    }
  }
}
