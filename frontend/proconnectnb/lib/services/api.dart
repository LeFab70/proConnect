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

  // ======================================================
  // AUTHENTIFICATION
  // ======================================================
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
      // CODE BACKEND AZURE
      final response = await http.post(
        Uri.parse("$baseUrl/api/auth/login"),
        headers: headers(),
        body: jsonEncode({"email": email, "password": password}),
      );
      // ... gestion des status codes
      */
    } catch (e) {
      return {"success": false, "message": "Erreur de connexion au serveur"};
    }
  }

  // ======================================================
  // AÎNÉS (Aines)
  // ======================================================

  // Récupérer la liste des aînés
  Future<List<dynamic>> getAines(String token) async {
    try {
      final response = await http.get(
        Uri.parse(
          "$baseUrl/api/Aine",
        ), // Vérifie si l'endpoint est /api/Aine ou /api/Aines
        headers: authHeaders(token),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      print("Erreur GET Aines: $e");
      return [];
    }
  }

  // Créer un aîné (UpsertAineRequestDto)
  Future<bool> registerAine({
    required Map<String, dynamic> data,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/Aine"),
        headers: authHeaders(token),
        body: jsonEncode(data),
      );

      print("Status Code Aine: ${response.statusCode}");
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Erreur POST Aine: $e");
      return false;
    }
  }

  // ======================================================
  // PROCHES AIDANTS (Caregivers)
  // ======================================================

  Future<List<dynamic>> getCaregivers(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/ProcheAidant"),
        headers: authHeaders(token),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> registerCaregiver({
    required String nom,
    required String prenom,
    required String telephone,
    required String email,
    Map<String, dynamic>? adresse,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/ProcheAidant"),
        headers: authHeaders(token),
        body: jsonEncode({
          "nom": nom,
          "prenom": prenom,
          "telephone": telephone,
          "email": email,
          "adresse": adresse,
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // ======================================================
  // MÉTHODES GÉNÉRIQUES (POST, PUT, DELETE)
  // ======================================================

  Future<bool> post(
    String endpoint,
    Map<String, dynamic> body,
    String token,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl${endpoint.startsWith('/') ? '' : '/'}$endpoint"),
        headers: authHeaders(token),
        body: jsonEncode(body),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Erreur POST générique : $e");
      return false;
    }
  }

  Future<bool> put(
    String endpoint,
    Map<String, dynamic> body,
    String token,
  ) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl${endpoint.startsWith('/') ? '' : '/'}$endpoint"),
        headers: authHeaders(token),
        body: jsonEncode(body),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  Future<bool> delete(String endpoint, String token) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl${endpoint.startsWith('/') ? '' : '/'}$endpoint"),
        headers: authHeaders(token),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print("Erreur DELETE : $e");
      return false;
    }
  }

  // ======================================================
  // AUTRES (Partages, Users)
  // ======================================================

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
  // ======================================================
  // RÉCUPÉRATION UTILISATEUR (Pour le Test API Screen)
  // ======================================================
  Future<Map<String, dynamic>?> getUser(int id) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/users/$id"), // Vérifie si ton endpoint C# est bien /api/users
        headers: headers(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      
      print("Erreur getUser: Status ${response.statusCode}");
      return null;
    } catch (e) {
      print("Exception getUser: $e");
      return null;
    }
  }
}
