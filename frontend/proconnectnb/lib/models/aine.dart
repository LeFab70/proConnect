class Aine {
  final int id;
  final String nom;
  final String prenom;
  final String telephone;
  final String email;
  final DateTime dateNaissance;
  final String docteur;
  final String numeroDocteur;

  Aine({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.email,
    required this.dateNaissance,
    required this.docteur,
    required this.numeroDocteur,
  });

  factory Aine.fromJson(Map<String, dynamic> json) {
    return Aine(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      telephone: json['telephone'],
      email: json['email'],
      dateNaissance: DateTime.parse(json['dateNaissance']),
      docteur: json['docteur'] ?? '',
      numeroDocteur: json['numeroTelephoneDocteur'] ?? '',
    );
  }
}