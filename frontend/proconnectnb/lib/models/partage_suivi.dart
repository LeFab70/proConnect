enum Autorisation { lecture, ecriture, complete }

enum StatutPartage { enAttente, actif, refuse }

class PartageSuivi {
  final int id;
  final Autorisation autorisation;
  final String relation;

  final int aineId;
  final int procheAidantId;

  // Email du proche invité, utile si son compte n’existe pas encore
  final String? procheEmail;

  final StatutPartage statut;

  const PartageSuivi({
    required this.id,
    required this.autorisation,
    required this.relation,
    required this.aineId,
    required this.procheAidantId,
    this.procheEmail,
    this.statut = StatutPartage.enAttente,
  });

  factory PartageSuivi.fromJson(Map<String, dynamic> json) {
    return PartageSuivi(
      id: _parseInt(json['id']),
      autorisation: _parseAutorisation(json['autorisation']),
      relation: json['relation']?.toString().trim().isNotEmpty == true
          ? json['relation'].toString().trim()
          : 'Proche aidant',
      aineId: _parseInt(json['aineId']),
      procheAidantId: _parseInt(json['procheAidantId']),
      procheEmail: json['procheEmail']?.toString(),
      statut: _parseStatut(json['statut']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'autorisation': autorisation.name,
      'relation': relation,
      'aineId': aineId,
      'procheAidantId': procheAidantId,
      'procheEmail': procheEmail,
      'statut': statut.name,
    };
  }

  PartageSuivi copyWith({
    int? id,
    Autorisation? autorisation,
    String? relation,
    int? aineId,
    int? procheAidantId,
    String? procheEmail,
    StatutPartage? statut,
  }) {
    return PartageSuivi(
      id: id ?? this.id,
      autorisation: autorisation ?? this.autorisation,
      relation: relation ?? this.relation,
      aineId: aineId ?? this.aineId,
      procheAidantId: procheAidantId ?? this.procheAidantId,
      procheEmail: procheEmail ?? this.procheEmail,
      statut: statut ?? this.statut,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static Autorisation _parseAutorisation(dynamic value) {
    final val = value?.toString().toLowerCase().trim() ?? '';

    switch (val) {
      case 'ecriture':
      case 'écriture':
        return Autorisation.ecriture;
      case 'complete':
      case 'complète':
        return Autorisation.complete;
      case 'lecture':
      default:
        return Autorisation.lecture;
    }
  }

  static StatutPartage _parseStatut(dynamic value) {
    final val = value?.toString().toLowerCase().trim() ?? '';

    switch (val) {
      case 'actif':
        return StatutPartage.actif;
      case 'refuse':
      case 'refusé':
        return StatutPartage.refuse;
      case 'enattente':
      case 'en_attente':
      case 'en attente':
      default:
        return StatutPartage.enAttente;
    }
  }

  bool get estActif => statut == StatutPartage.actif;
  bool get estEnAttente => statut == StatutPartage.enAttente;
  bool get estRefuse => statut == StatutPartage.refuse;

  @override
  String toString() {
    return 'PartageSuivi(id: $id, aineId: $aineId, procheAidantId: $procheAidantId, procheEmail: $procheEmail, relation: $relation, autorisation: ${autorisation.name}, statut: ${statut.name})';
  }
}
