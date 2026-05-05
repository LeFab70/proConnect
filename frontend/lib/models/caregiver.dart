import 'adresse.dart'; 

class Caregiver {
  final int id;
  final String nom;
  final String prenom;
  final String telephone;
  final String email;
  final Adresse? adresse; 

  Caregiver({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.email,
    this.adresse,
  });

  // =========================
  // FROM JSON (Réponse DTO)
  // =========================
  factory Caregiver.fromJson(Map<String, dynamic> json) {
    return Caregiver(
      id: _parseInt(json['id']),
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      telephone: json['telephone'] ?? '',
      email: json['email'] ?? '',
      adresse: json['adresse'] != null 
          ? Adresse.fromJson(json['adresse']) 
          : null,
    );
  }

  // =========================
  // TO JSON (Upsert DTO)
  // =========================
  Map<String, dynamic> toJson() {
    return {
      "nom": nom,
      "prenom": prenom,
      "telephone": telephone,
      "email": email,
      "adresse": adresse?.toJson(),
    };
  }

  // =========================
  // COPY WITH
  // =========================
  Caregiver copyWith({
    int? id,
    String? nom,
    String? prenom,
    String? telephone,
    String? email,
    Adresse? adresse,
  }) {
    return Caregiver(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
      adresse: adresse ?? this.adresse,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}