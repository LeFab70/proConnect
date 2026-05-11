import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/appointment.dart';
import 'api.dart';

class AppointmentService {
  final Api _api = Api();

  // Fabrice | 2026-05-05T04:47:29Z | Endpoints alignés sur MapRendezVousMedicaux (/api/rendez-vous-medicaux).

  Future<List<RendezVousMedical>> getAppointments(String token) async {
    try {
      final response = await http.get(
        Uri.parse("${_api.baseUrl}/api/rendez-vous-medicaux"),
        headers: _api.authHeaders(token),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          return decoded
              .map((item) => RendezVousMedical.fromJson(item))
              .toList();
        }

        return [];
      }

      throw Exception("Erreur ${response.statusCode}: ${response.body}");
    } catch (e) {
      throw Exception("Erreur chargement rendez-vous: $e");
    }
  }

  Future<RendezVousMedical?> createAppointment(
    Map<String, dynamic> data,
    String token,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("${_api.baseUrl}/api/rendez-vous-medicaux"),
        headers: _api.authHeaders(token),
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return RendezVousMedical.fromJson(decoded);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateAppointment(
    int id,
    Map<String, dynamic> data,
    String token,
  ) async {
    try {
      final response = await http.put(
        Uri.parse("${_api.baseUrl}/api/rendez-vous-medicaux/$id"),
        headers: _api.authHeaders(token),
        body: jsonEncode(data),
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteAppointment(int id, String token) async {
    try {
      final response = await http.delete(
        Uri.parse("${_api.baseUrl}/api/rendez-vous-medicaux/$id"),
        headers: _api.authHeaders(token),
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}