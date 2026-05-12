import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'services/secrets.dart';

class Api {
  Api({
    this.baseUrl =
        'https://proconnectnb-d2bxe6embxg2e7h7.eastus2-01.azurewebsites.net',
  });

  final String baseUrl;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim().toLowerCase(),
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'success': true,
          'token': data['accessToken'],
          'role': data['role'],
          'firstName': data['firstName'] ?? email.split('@')[0],
          'userId': data['userId'],
          'profilePicture': data['profilePicture'],
          'nbDemandes': data['nbDemandes'] ?? 0,
        };
      }

      return {'success': false, 'message': 'Email ou mot de passe incorrect'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion au serveur'};
    }
  }

  Future<Map<String, dynamic>> register({
    required String nom,
    required String prenom,
    required String telephone,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'nom': nom.trim(),
          'prenom': prenom.trim(),
          'telephone': telephone.trim(),
          'email': email.trim().toLowerCase(),
          'password': password,
          'role': role.trim().toUpperCase(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        return {
          'success': true,
          'token': data['accessToken'] ?? data['token'],
          'role': data['role'] ?? role.trim().toUpperCase(),
          'firstName': data['firstName'] ?? data['prenom'] ?? prenom,
          'userId': data['userId'] ?? data['id'],
          'profilePicture': data['profilePicture'],
          'nbDemandes': data['nbDemandes'] ?? 0,
        };
      }

      String message = "Erreur création compte";

      try {
        final errorData = jsonDecode(response.body);
        message = errorData['message']?.toString() ?? message;
      } catch (_) {}

      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion au serveur'};
    }
  }

  Future<String> getUser(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/users/$id'));

    if (response.statusCode == 200) return response.body;
    if (response.statusCode == 404) return 'Utilisateur introuvable';

    return 'Erreur: ${response.statusCode}';
  }

  Future<bool> put(
    String endpoint,
    Map<String, dynamic> body,
    String token,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-api-key': Secrets.apiKey,
        },
        body: jsonEncode(body),
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint('PUT ERROR: $e');
      return false;
    }
  }

  Future<bool> rejectPartage(int partageId, String token) async {
    return await put('/api/partages-suivi/$partageId/reject', {}, token);
  }
}
