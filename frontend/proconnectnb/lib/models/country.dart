class Country {
  final String name;
  final String code;
  final String flag;

  Country({required this.name, required this.code, required this.flag});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name']['common'], // Nom commun du pays
      code: json['cca2'],           // Code ISO (ex: CA, FR)
      flag: json['flags']['png'],   // URL de l'image du drapeau
    );
  }
}