import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/appointment.dart';
import 'api.dart';

class AppointmentService {
  final Api _api = Api();

  Future<List<RendezVousMedical>> getAppointments(String token) async {
    try {
      final response = await http.get(
        Uri.parse("${_api.baseUrl}/api/RendezVousMedicaux"),
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

  Future<bool> createAppointment(
    Map<String, dynamic> data,
    String token,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("${_api.baseUrl}/api/RendezVousMedicaux"),
        headers: _api.authHeaders(token),
        body: jsonEncode(data),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateAppointment(
    int id,
    Map<String, dynamic> data,
    String token,
  ) async {
    try {
      final response = await http.put(
        Uri.parse("${_api.baseUrl}/api/RendezVousMedicaux/$id"),
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
        Uri.parse("${_api.baseUrl}/api/RendezVousMedicaux/$id"),
        headers: _api.authHeaders(token),
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}