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

  // --- FACTORY POUR L'IA ---
  // Cette méthode permet de transformer le résultat de l'IA (JSON) en objet Dart automatiquement
  factory ActiviteIA.fromJson(Map<String, dynamic> json) {
    return ActiviteIA(
      id: json['id'] ?? 0,
      titre: json['titre'] ?? 'Activité sans titre',
      description: json['description'] ?? '',
      // Conversion sécurisée de la date venant du JSON
      dateHeure: DateTime.parse(json['dateHeure'] ?? DateTime.now().toIso8601String()),
      lieu: json['lieu'] ?? 'Lieu non spécifié',
      categorie: json['categorie'] ?? 'Général',
      scorePertinence: (json['score_pertinence'] ?? 1.0).toDouble(),
      region: json['region'] ?? 'Inconnue',
    );
  }
}