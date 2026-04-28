class AppUser {
  final String nom;
  final String prenom;
  final String telephone;
  final String email;
  final String? role;

  AppUser({
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.email,
    this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'email': email,
      'role': role,
    };
  }
}