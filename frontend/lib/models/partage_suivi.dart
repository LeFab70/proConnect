enum Autorisation { lecture, ecriture, complete }

enum StatutPartage { enAttente, actif, refuse }

class PartageSuivi {
  final int id;
  final Autorisation autorisation;
  final String relation;

  final int aineId;
  final int procheAidantId;

  final String? procheEmail;

  final String? aineNom;
  final String? ainePrenom;
  final String? aineEmail;

  final String? procheNom;
  final String? prochePrenom;
  final String? procheTelephone;

  final StatutPartage statut;

  const PartageSuivi({
    required this.id,
    required this.autorisation,
    required this.relation,
    required this.aineId,
    required this.procheAidantId,
    this.procheEmail,
    this.aineNom,
    this.ainePrenom,
    this.aineEmail,
    this.procheNom,
    this.prochePrenom,
    this.procheTelephone,
    this.statut = StatutPartage.enAttente,
  });

  factory PartageSuivi.fromJson(Map<String, dynamic> json) {
    return PartageSuivi(
      id: _parseInt(json['id']),
      autorisation: _parseAutorisation(json['autorisation']),
      relation: _parseRelation(json['relation']),
      aineId: _parseInt(json['aineId']),
      procheAidantId: _parseInt(json['procheAidantId']),
      procheEmail: _parseNullableString(json['procheEmail']),
      aineNom: _parseNullableString(json['aineNom'] ?? json['nomAine']),
      ainePrenom: _parseNullableString(
        json['ainePrenom'] ?? json['prenomAine'],
      ),
      aineEmail: _parseNullableString(json['aineEmail']),
      procheNom: _parseNullableString(json['procheNom'] ?? json['nomProche']),
      prochePrenom: _parseNullableString(
        json['prochePrenom'] ?? json['prenomProche'],
      ),
      procheTelephone: _parseNullableString(
        json['procheTelephone'] ?? json['telephoneProche'],
      ),
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
      'aineNom': aineNom,
      'ainePrenom': ainePrenom,
      'aineEmail': aineEmail,
      'procheNom': procheNom,
      'prochePrenom': prochePrenom,
      'procheTelephone': procheTelephone,
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
    String? aineNom,
    String? ainePrenom,
    String? aineEmail,
    String? procheNom,
    String? prochePrenom,
    String? procheTelephone,
    StatutPartage? statut,
  }) {
    return PartageSuivi(
      id: id ?? this.id,
      autorisation: autorisation ?? this.autorisation,
      relation: relation ?? this.relation,
      aineId: aineId ?? this.aineId,
      procheAidantId: procheAidantId ?? this.procheAidantId,
      procheEmail: procheEmail ?? this.procheEmail,
      aineNom: aineNom ?? this.aineNom,
      ainePrenom: ainePrenom ?? this.ainePrenom,
      aineEmail: aineEmail ?? this.aineEmail,
      procheNom: procheNom ?? this.procheNom,
      prochePrenom: prochePrenom ?? this.prochePrenom,
      procheTelephone: procheTelephone ?? this.procheTelephone,
      statut: statut ?? this.statut,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static String _parseRelation(dynamic value) {
    final relation = value?.toString().trim() ?? '';
    return relation.isNotEmpty ? relation : 'Proche aidant';
  }

  static String? _parseNullableString(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return text;
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

  String get aineNomComplet {
    final nomComplet = '${ainePrenom ?? ''} ${aineNom ?? ''}'.trim();
    return nomComplet.isNotEmpty ? nomComplet : 'Aîné inconnu';
  }

  String get procheNomComplet {
    final nomComplet = '${prochePrenom ?? ''} ${procheNom ?? ''}'.trim();
    return nomComplet.isNotEmpty ? nomComplet : 'Proche inconnu';
  }

  bool get estActif => statut == StatutPartage.actif;
  bool get estEnAttente => statut == StatutPartage.enAttente;
  bool get estRefuse => statut == StatutPartage.refuse;

  @override
  String toString() {
    return 'PartageSuivi(id: $id, aineId: $aineId, procheAidantId: $procheAidantId, procheEmail: $procheEmail, aineNomComplet: $aineNomComplet, procheNomComplet: $procheNomComplet, relation: $relation, autorisation: ${autorisation.name}, statut: ${statut.name})';
  }
}
