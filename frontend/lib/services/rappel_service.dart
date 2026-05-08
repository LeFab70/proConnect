import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/rappel.dart';
import 'api.dart';

class RappelService {
  final Api _api = Api();

  Future<List<Rappel>> getRappels(String token) async {
    final response = await http.get(
      Uri.parse("${_api.baseUrl}/api/rappels"),
      headers: _api.authHeaders(token),
    );

    debugPrint("GET RAPPELS STATUS: ${response.statusCode}");
    debugPrint("GET RAPPELS RESPONSE: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Erreur ${response.statusCode}: ${response.body}");
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) return [];

    return decoded
        .map((e) => Rappel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

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
    final body = upsertBody(r);

    debugPrint("CREATE RAPPEL BODY: ${jsonEncode(body)}");

    final response = await http.post(
      Uri.parse("${_api.baseUrl}/api/rappels"),
      headers: _api.authHeaders(token),
      body: jsonEncode(body),
    );

    debugPrint("CREATE RAPPEL STATUS: ${response.statusCode}");
    debugPrint("CREATE RAPPEL RESPONSE: ${response.body}");

    if (response.statusCode != 200 &&
        response.statusCode != 201 &&
        response.statusCode != 204) {
      return null;
    }

    if (response.body.trim().isEmpty) {
      return r.id;
    }

    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      final id =
          decoded['id'] ??
          decoded['Id'] ??
          decoded['rappelId'] ??
          decoded['RappelId'];

      if (id is int) return id;

      return int.tryParse(id?.toString() ?? '');
    }

    if (decoded is int) {
      return decoded;
    }

    return r.id;
  }

  Future<bool> updateRappel(int id, Rappel r, String token) async {
    final body = upsertBody(r);

    debugPrint("UPDATE RAPPEL BODY: ${jsonEncode(body)}");

    final response = await http.put(
      Uri.parse("${_api.baseUrl}/api/rappels/$id"),
      headers: _api.authHeaders(token),
      body: jsonEncode(body),
    );

    debugPrint("UPDATE RAPPEL STATUS: ${response.statusCode}");
    debugPrint("UPDATE RAPPEL RESPONSE: ${response.body}");

    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<bool> deleteRappel(int id, String token) async {
    final response = await http.delete(
      Uri.parse("${_api.baseUrl}/api/rappels/$id"),
      headers: _api.authHeaders(token),
    );

    debugPrint("DELETE RAPPEL STATUS: ${response.statusCode}");
    debugPrint("DELETE RAPPEL RESPONSE: ${response.body}");

    return response.statusCode == 200 || response.statusCode == 204;
  }
}
