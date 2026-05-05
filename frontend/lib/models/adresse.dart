class Adresse {
  final String? numero;
  final String? rue;
  final String? ville;
  final String? codePostal;
  final String? province;

  Adresse({
    this.numero,
    this.rue,
    this.ville,
    this.codePostal,
    this.province,
  });

  // Fabrice | 2026-05-05T05:02:10Z | Alignement avec AdresseDto backend (numero, province).
  factory Adresse.fromJson(Map<String, dynamic> json) {
    return Adresse(
      numero: json['numero']?.toString(),
      rue: json['rue']?.toString(),
      ville: json['ville']?.toString(),
      codePostal: json['codePostal']?.toString(),
      province: json['province']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (numero != null && numero!.trim().isNotEmpty) "numero": numero,
        if (rue != null && rue!.trim().isNotEmpty) "rue": rue,
        if (ville != null && ville!.trim().isNotEmpty) "ville": ville,
        if (codePostal != null && codePostal!.trim().isNotEmpty)
          "codePostal": codePostal,
        if (province != null && province!.trim().isNotEmpty)
          "province": province,
      };
}
