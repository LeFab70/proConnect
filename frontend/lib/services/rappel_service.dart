import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/rappel.dart';
import 'api.dart';

class RappelService {
  final Api _api = Api();

  // Fabrice | 2026-05-05T04:56:37Z | GET /api/rappels aligné sur RappelResponseDto.
  Future<List<Rappel>> getRappels(String token) async {
    final response = await http.get(
      Uri.parse("${_api.baseUrl}/api/rappels"),
      headers: _api.authHeaders(token),
    );

    if (response.statusCode != 200) {
      throw Exception("Erreur ${response.statusCode}: ${response.body}");
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) return [];

    return decoded
        .map((e) => Rappel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Corps conforme à UpsertRappelRequestDto (sans id ni dates calculées serveur).
  // Fabrice | 2026-05-05T04:56:37Z | TimeOnly ASP.NET attend souvent HH:mm:ss.
  String _normalizeHeureDebut(String h) {
    final parts = h.split(':');
    if (parts.length == 2) {
      final hh = parts[0].padLeft(2, '0');
      final mm = parts[1].padLeft(2, '0');
      return '$hh:$mm:00';
    }
    if (parts.length >= 3) return h;
    return '${parts.first.padLeft(2, '0')}:00:00';
  }

  Map<String, dynamic> upsertBody(Rappel r) {
    return {
      'dateDebut': Rappel.formatDateOnlyStatic(r.dateDebut),
      'heureDebut': _normalizeHeureDebut(r.heureDebut),
      'minutesAvantRappel': r.minutesAvantRappel,
      'type': r.type,
      'actif': r.actif,
      if (r.medicamentId != null) 'medicamentId': r.medicamentId,
      if (r.rendezVousMedicalId != null)
        'rendezVousMedicalId': r.rendezVousMedicalId,
    };
  }

  Future<int?> createRappel(Rappel r, String token) async {
    final response = await http.post(
      Uri.parse("${_api.baseUrl}/api/rappels"),
      headers: _api.authHeaders(token),
      body: jsonEncode(upsertBody(r)),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      return null;
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      final id = decoded['id'];
      if (id is int) return id;
      return int.tryParse(id?.toString() ?? '');
    }
    return null;
  }

  Future<bool> updateRappel(int id, Rappel r, String token) async {
    final response = await http.put(
      Uri.parse("${_api.baseUrl}/api/rappels/$id"),
      headers: _api.authHeaders(token),
      body: jsonEncode(upsertBody(r)),
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<bool> deleteRappel(int id, String token) async {
    final response = await http.delete(
      Uri.parse("${_api.baseUrl}/api/rappels/$id"),
      headers: _api.authHeaders(token),
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }
}
