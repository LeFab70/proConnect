import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/activity.dart';
import 'api.dart';

class CommunityAiService {
  final Api _api = Api();

  // Fabrice | 2026-05-05T04:56:37Z | POST /api/activites/suggestions (JWT requis).
  Future<List<ActiviteIA>> fetchSuggestions({
    required String token,
    required String adresse,
    String? interets,
    int limit = 10,
  }) async {
    final response = await http.post(
      Uri.parse("${_api.baseUrl}/api/activites/suggestions"),
      headers: _api.authHeaders(token),
      body: jsonEncode({
        'adresse': adresse,
        if (interets != null && interets.isNotEmpty) 'interets': interets,
        'limit': limit,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Erreur ${response.statusCode}: ${response.body}");
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) return [];

    return decoded.map((raw) {
      final m = raw as Map<String, dynamic>;
      final dh = m['dateHeure'];
      final parsedDate = dh != null
          ? DateTime.tryParse(dh.toString()) ?? DateTime.now()
          : DateTime.now();
      final titre = m['titre']?.toString() ?? 'Activité';
      final lieu = m['lieu']?.toString() ?? adresse;
      return ActiviteIA(
        // Fabrice | 2026-05-05T06:00:00Z | Identifiant stable pour permettre favoris locaux.
        id: Object.hash(titre, parsedDate.toIso8601String(), lieu, adresse),
        titre: titre,
        description: m['description']?.toString() ?? '',
        dateHeure: parsedDate,
        lieu: lieu,
        categorie: 'Communautaire',
        scorePertinence: 1.0,
        region: adresse,
        source: 'proconnect',
      );
    }).toList();
  }
}
