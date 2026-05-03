enum UserRole { aine, aidant, admin }

class AppUser {
  final int id;
  final String nom;
  final String prenom;
  final String telephone;
  final String email;
  final UserRole role;

  AppUser({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.email,
    required this.role,
  });

  // =========================
  // FROM JSON (ROBUSTE)
  // =========================
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: _parseInt(json['id']),
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      telephone: json['telephone'] ?? '',
      email: json['email'] ?? '',
      role: _parseRole(json['role']),
    );
  }

  // =========================
  // TO JSON (BACKEND)
  // =========================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'email': email,
      'role': role.name.toUpperCase(), // AINE / AIDANT
    };
  }

  // =========================
  // COPY WITH (UI)
  // =========================
  AppUser copyWith({
    int? id,
    String? nom,
    String? prenom,
    String? telephone,
    String? email,
    UserRole? role,
  }) {
    return AppUser(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }

  // =========================
  // HELPERS
  // =========================
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static UserRole _parseRole(dynamic value) {
    if (value == null) return UserRole.aine;

    switch (value.toString().toUpperCase()) {
      case 'AIDANT':
        return UserRole.aidant;
      case 'ADMIN':
        return UserRole.admin;
      default:
        return UserRole.aine;
    }
  }

  @override
  String toString() {
    return 'User($prenom $nom - ${role.name})';
  }
}
