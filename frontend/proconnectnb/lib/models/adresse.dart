class Adresse {
  final String? rue;
  final String? ville;
  final String? codePostal;

  Adresse({this.rue, this.ville, this.codePostal});

  factory Adresse.fromJson(Map<String, dynamic> json) {
    return Adresse(
      rue: json['rue'],
      ville: json['ville'],
      codePostal: json['codePostal'],
    );
  }

  Map<String, dynamic> toJson() => {
    "rue": rue,
    "ville": ville,
    "codePostal": codePostal,
  };
}