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

    var index = 0;
    return decoded.map((raw) {
      final m = raw as Map<String, dynamic>;
      final dh = m['dateHeure'];
      return ActiviteIA(
        id: index++,
        titre: m['titre']?.toString() ?? 'Activité',
        description: m['description']?.toString() ?? '',
        dateHeure: dh != null
            ? DateTime.tryParse(dh.toString()) ?? DateTime.now()
            : DateTime.now(),
        lieu: m['lieu']?.toString() ?? adresse,
        categorie: 'Communautaire',
        scorePertinence: 1.0,
        region: adresse,
      );
    }).toList();
  }
}
