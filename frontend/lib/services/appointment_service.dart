import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/appointment.dart';
import 'api.dart';
import 'package:flutter/foundation.dart';

class AppointmentService {
  final Api _api = Api();

  /// PostgreSQL/Npgsql attend un instant UTC pour `timestamptz`. Normalise ici pour
  /// tous les appelants (évite les 500 si une écran oublie `.toUtc()` ou si l'APK est ancien).
  static Map<String, dynamic> _payloadWithUtcDateHeure(Map<String, dynamic> data) {
    final copy = Map<String, dynamic>.from(data);
    final raw = copy['dateHeure'];
    DateTime? parsed;
    if (raw is String) {
      parsed = DateTime.tryParse(raw);
    } else if (raw is DateTime) {
      parsed = raw;
    }
    if (parsed != null) {
      copy['dateHeure'] = parsed.toUtc().toIso8601String();
    }
    return copy;
  }

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

  Future<Map<String, dynamic>> createAppointment(
    Map<String, dynamic> data,
    String token,
  ) async {
    try {
      final payload = _payloadWithUtcDateHeure(data);
      if (kDebugMode) {
        debugPrint("RDV CREATE REQUEST: ${jsonEncode(payload)}");
      }
      final response = await http.post(
        Uri.parse("${_api.baseUrl}/api/rendez-vous-medicaux"),
        headers: _api.authHeaders(token),
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return {
            "success": true,
            "appointment": RendezVousMedical.fromJson(decoded),
          };
        }
      }

      if (kDebugMode) {
        debugPrint("RDV CREATE STATUS: ${response.statusCode}");
        debugPrint("RDV CREATE BODY: ${response.body}");
      }
      // Try to parse backend error message (often { "message": "..." }).
      String message = "Échec de création";
      try {
        final err = jsonDecode(response.body);
        if (err is Map<String, dynamic>) {
          // ValidationProblemDetails: {title:"...", errors:{Field:["msg"]}}
          if (err["errors"] is Map) {
            final errors = err["errors"] as Map;
            for (final entry in errors.entries) {
              final v = entry.value;
              if (v is List && v.isNotEmpty) {
                message = v.first.toString();
                break;
              }
            }
          }

          final detail = err["detail"]?.toString();
          final title = err["title"]?.toString();
          final serverMsg = err["message"]?.toString();

          if (message == "Échec de création") {
            message = serverMsg ?? detail ?? title ?? message;
          } else if (detail != null &&
              detail.isNotEmpty &&
              !message.contains(detail)) {
            message = "$message ($detail)";
          }
        }
      } catch (_) {}

      return {
        "success": false,
        "message": message,
        "status": response.statusCode,
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint("RDV CREATE EXCEPTION: $e");
      }
      return {
        "success": false,
        "message": "Erreur de connexion au serveur",
      };
    }
  }

  Future<bool> updateAppointment(
    int id,
    Map<String, dynamic> data,
    String token,
  ) async {
    try {
      final payload = _payloadWithUtcDateHeure(data);
      final response = await http.put(
        Uri.parse("${_api.baseUrl}/api/rendez-vous-medicaux/$id"),
        headers: _api.authHeaders(token),
        body: jsonEncode(payload),
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