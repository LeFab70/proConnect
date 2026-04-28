import 'dart:convert';
import 'package:http/http.dart' as http;
import 'secrets.dart';
import '../../models/partage_suivi.dart';

class Api {
  final String baseUrl =
      "https://proconnectnb-d2bxe6embxg2e7h7.eastus2-01.azurewebsites.net";

  Map<String, String> headers() {
    return {"Content-Type": "application/json", "x-api-key": Secrets.apiKey};
  }

  Map<String, String> authHeaders(String token) {
    return {
      "Content-Type": "application/json",
      "x-api-key": Secrets.apiKey,
      "Authorization": "Bearer $token",
    };
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      final mockUsers = {
        "test@test.com": {
          "password": "12345678",
          "token": "mock_token_123",
          "firstName": "TestUser",
          "role": "AINE",
        },
        "aidant@test.com": {
          "password": "12345678",
          "token": "mock_token_456",
          "firstName": "AidantUser",
          "role": "AIDANT",
        },
      };

      if (!mockUsers.containsKey(email)) {
        return {"success": false, "message": "Utilisateur introuvable"};
      }

      final user = mockUsers[email]!;

      if (user["password"] != password) {
        return {"success": false, "message": "Mot de passe incorrect"};
      }

      return {
        "success": true,
        "token": user["token"],
        "firstName": user["firstName"],
        "role": user["role"],
      };

      /*
      // BACKEND PLUS TARD
      final response = await http.post(
        Uri.parse("$baseUrl/api/auth/login"),
        headers: headers(),
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "success": true,
          "token": data["token"],
          "firstName": data["firstName"],
          "role": data["role"],
        };
      }

      if (response.statusCode == 401) {
        return {
          "success": false,
          "message": "Email ou mot de passe incorrect",
        };
      }

      if (response.statusCode == 404) {
        return {
          "success": false,
          "message": "Utilisateur introuvable",
        };
      }

      if (response.statusCode == 403) {
        return {
          "success": false,
          "message": "Accès refusé",
        };
      }

      return {
        "success": false,
        "message": "Erreur serveur: ${response.statusCode}",
      };
      */
    } catch (e) {
      return {"success": false, "message": "Erreur de connexion au serveur"};
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      return {
        "success": true,
        "email": data["email"],
        "firstName": data["prenom"],
        "role": data["role"],
      };

      /*
      final response = await http.post(
        Uri.parse("$baseUrl/api/auth/register"),
        headers: headers(),
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": true,
          ...jsonDecode(response.body),
        };
      }

      if (response.statusCode == 409) {
        return {
          "success": false,
          "message": "Un compte existe déjà avec cet email",
        };
      }

      if (response.statusCode == 400) {
        return {
          "success": false,
          "message": "Informations invalides",
        };
      }

      return {
        "success": false,
        "message": "Erreur serveur: ${response.statusCode}",
      };
      */
    } catch (e) {
      return {"success": false, "message": "Erreur de connexion au serveur"};
    }
  }

  Future<bool> registerCaregiver({
    required String nom,
    required String prenom,
    required String telephone,
    required String email,
    required String relation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/ProcheAidant"),
        headers: headers(),
        body: jsonEncode({
          "nom": nom,
          "prenom": prenom,
          "telephone": telephone,
          "email": email,
          "relation": relation,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> upsertPartage(PartageSuivi partage, String token) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/PartageSuivi"),
        headers: authHeaders(token),
        body: jsonEncode(partage.toJson()),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUser(int id) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/users/$id"),
        headers: headers(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
