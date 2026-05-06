import 'adresse.dart';

class Aine {
  final int id;
  final String nom;
  final String prenom;
  final String telephone;
  final String email;
  final DateTime dateNaissance;
  final Adresse? adresse; 
  final String docteur;
  final String numeroDocteur;

  Aine({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.email,
    required this.dateNaissance,
    this.adresse,
    this.docteur = '',
    this.numeroDocteur = '',
  });

  // =========================
  // FROM JSON
  // =========================
  factory Aine.fromJson(Map<String, dynamic> json) {
    return Aine(
      id: _parseInt(json['id']),
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      telephone: json['telephone'] ?? '',
      email: json['email'] ?? '',
      dateNaissance: _parseDate(json['dateNaissance']),
      adresse: json['adresse'] != null
          ? Adresse.fromJson(json['adresse'])
          : null,
      docteur: json['docteur'] ?? '',
      numeroDocteur: json['numeroTelephoneDocteur'] ?? '',
    );
  }

  // =========================
  // TO JSON (Format Azure / C#)
  // =========================
  Map<String, dynamic> toJson() {
    return {
      "nom": nom,
      "prenom": prenom,
      "telephone": telephone,
      "email": email,
      "dateNaissance":
          "${dateNaissance.year.toString().padLeft(4, '0')}-${dateNaissance.month.toString().padLeft(2, '0')}-${dateNaissance.day.toString().padLeft(2, '0')}",
      "adresse": adresse?.toJson(),
      "docteur": docteur,
      "numeroTelephoneDocteur": numeroDocteur,
    };
  }

  // =========================
  // HELPERS
  // =========================
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
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
