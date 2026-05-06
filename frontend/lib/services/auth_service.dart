import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api.dart';

/// Service d’auth HTTP bas niveau ; l’app préfère [AuthProvider] + [Api.login].
class AuthService {
  final String baseUrl =
      "https://proconnectnb-d2bxe6embxg2e7h7.eastus2-01.azurewebsites.net";

  // Fabrice | 2026-05-05T04:47:29Z | POST /api/auth/login aligné sur LoginRequestDto (email + password).
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/auth/login"),
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        debugPrint("❌ Login error: ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("🔥 Exception login: $e");
      return null;
    }
  }

  /// Enrichit la réponse brute avec prénom et rôle comme [Api.login].
  Future<Map<String, dynamic>> loginWithProfile(
    String email,
    String password,
  ) async {
    final api = Api();
    return api.login(email, password);
  }
}
