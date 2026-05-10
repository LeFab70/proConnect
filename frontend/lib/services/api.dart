import 'package:flutter/foundation.dart';
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

  // Fabrice | 2026-05-05T04:47:29Z | Appelle POST /api/auth/login puis déduit rôle et prénom pour AuthProvider.
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/auth/login"),
        headers: headers(),
        body: jsonEncode({"email": email.trim(), "password": password}),
      );

      if (response.statusCode == 401) {
        return {"success": false, "message": "Email ou mot de passe incorrect"};
      }

      if (response.statusCode != 200) {
        return {
          "success": false,
          "message": "Erreur serveur (${response.statusCode})",
        };
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final accessToken =
          (body["accessToken"] ?? body["AccessToken"]) as String?;
      if (accessToken == null || accessToken.isEmpty) {
        return {"success": false, "message": "Réponse serveur invalide"};
      }

      final profile = await _fetchLoginProfile(
        accessToken,
        email.trim().toLowerCase(),
      );

      return {
        "success": true,
        "token": accessToken,
        "firstName": profile["firstName"],
        "role": profile["role"],
        "userId": profile["userId"],
      };
    } catch (e) {
      return {"success": false, "message": "Erreur de connexion au serveur"};
    }
  }

  // Fabrice | 2026-05-05T04:47:29Z | Enchaîne /api/auth/me, /api/aines et /api/proches-aidants pour le rôle UI.
  Future<Map<String, dynamic>> _fetchLoginProfile(
    String token,
    String emailLower,
  ) async {
    int? userId;
    String? meEmail;

    final meResp = await http.get(
      Uri.parse("$baseUrl/api/auth/me"),
      headers: authHeaders(token),
    );
    if (meResp.statusCode == 200) {
      final me = jsonDecode(meResp.body) as Map<String, dynamic>;
      userId = _parseId(me["userId"]);
      meEmail = me["email"]?.toString().toLowerCase();
    }

    final matchEmail = (meEmail != null && meEmail.isNotEmpty)
        ? meEmail
        : emailLower;

    final ainesResp = await http.get(
      Uri.parse("$baseUrl/api/aines"),
      headers: authHeaders(token),
    );
    if (ainesResp.statusCode == 200) {
      final list = jsonDecode(ainesResp.body) as List<dynamic>;
      for (final raw in list) {
        final m = raw as Map<String, dynamic>;
        if (m["email"]?.toString().toLowerCase() == matchEmail) {
          return {
            "userId": userId ?? _parseId(m["id"]),
            "firstName": m["prenom"] ?? matchEmail.split("@").first,
            "role": "AINE",
          };
        }
      }
    }

    final paResp = await http.get(
      Uri.parse("$baseUrl/api/proches-aidants"),
      headers: authHeaders(token),
    );
    if (paResp.statusCode == 200) {
      final list = jsonDecode(paResp.body) as List<dynamic>;
      for (final raw in list) {
        final m = raw as Map<String, dynamic>;
        if (m["email"]?.toString().toLowerCase() == matchEmail) {
          return {
            "userId": userId ?? _parseId(m["id"]),
            "firstName": m["prenom"] ?? matchEmail.split("@").first,
            "role": "AIDANT",
          };
        }
      }
    }

    if (userId != null) {
      final uResp = await http.get(
        Uri.parse("$baseUrl/api/users/$userId"),
        headers: authHeaders(token),
      );
      if (uResp.statusCode == 200) {
        final u = jsonDecode(uResp.body) as Map<String, dynamic>;
        return {
          "userId": userId,
          "firstName": u["prenom"] ?? matchEmail.split("@").first,
          "role": "AIDANT",
        };
      }
    }

    return {
      "userId": userId,
      "firstName": matchEmail.split("@").first,
      "role": "AIDANT",
    };
  }

  int? _parseId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  // Fabrice | 2026-05-05T04:47:29Z | Inscription StandardUser puis même enrichissement que le login.
  Future<Map<String, dynamic>> register({
    required String nom,
    required String prenom,
    required String telephone,
    required String email,
    required String password,
    String? role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/auth/register"),
        headers: headers(),
        body: jsonEncode({
          "nom": nom,
          "prenom": prenom,
          "telephone": telephone,
          "email": email.trim(),
          "password": password,
          if (role != null && role.trim().isNotEmpty) "role": role.trim(),
        }),
      );

      if (response.statusCode == 400) {
        final err = _parseRegisterError(response.body);
        return {
          "success": false,
          "message": err ?? "Impossible de créer le compte",
        };
      }

      if (response.statusCode != 200) {
        return {
          "success": false,
          "message": "Erreur serveur (${response.statusCode})",
        };
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final accessToken =
          (body["accessToken"] ?? body["AccessToken"]) as String?;
      if (accessToken == null || accessToken.isEmpty) {
        return {"success": false, "message": "Réponse serveur invalide"};
      }

      final profile = await _fetchLoginProfile(
        accessToken,
        email.trim().toLowerCase(),
      );

      return {
        "success": true,
        "token": accessToken,
        "firstName": profile["firstName"],
        "role": profile["role"],
        "userId": profile["userId"],
      };
    } catch (e) {
      return {"success": false, "message": "Erreur de connexion au serveur"};
    }
  }

  String? _parseRegisterError(String body) {
    try {
      final m = jsonDecode(body);
      if (m is Map<String, dynamic>) {
        return m["error"]?.toString();
      }
    } catch (_) {}
    return null;
  }

  // ======================================================
  // AÎNÉS (Aines)
  // ======================================================

  // Fabrice | 2026-05-05T04:47:29Z | Liste les aînés via la route ASP.NET /api/aines.
  Future<List<dynamic>> getAines(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/aines"),
        headers: authHeaders(token),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      debugPrint("Erreur GET Aines: $e");
      return [];
    }
  }

  // Fabrice | 2026-05-05T04:47:29Z | Crée un aîné (admin API uniquement si JWT Admin).
  Future<bool> registerAine({
    required Map<String, dynamic> data,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/aines"),
        headers: authHeaders(token),
        body: jsonEncode(data),
      );

      debugPrint("Status Code Aine: ${response.statusCode}");
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("Erreur POST Aine: $e");
      return false;
    }
  }

  // ======================================================
  // PROCHES AIDANTS (Caregivers)
  // ======================================================

  Future<List<dynamic>> getCaregivers(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/proches-aidants"),
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
        Uri.parse("$baseUrl/api/proches-aidants"),
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
      debugPrint("Erreur POST générique : $e");
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
      debugPrint("Erreur DELETE : $e");
      return false;
    }
  }

  // ======================================================
  // AUTRES (Partages, Users)
  // ======================================================

  // Fabrice | 2026-05-05T04:47:29Z | Corps aligné sur UpsertPartageSuiviRequestDto (autorisation Pascal côté API).
  Future<bool> upsertPartage(PartageSuivi partage, String token) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/partages-suivi"),
        headers: authHeaders(token),
        body: jsonEncode({
          "autorisation": _partageAutorisationApi(partage.autorisation),
          "relation": partage.relation,
          "aineId": partage.aineId,
          if (partage.procheAidantId > 0)
            "procheAidantId": partage.procheAidantId,
          if (partage.procheEmail != null &&
              partage.procheEmail!.trim().isNotEmpty)
            "procheEmail": partage.procheEmail!.trim().toLowerCase(),
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> acceptPartage(int partageId, String token) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/partages-suivi/$partageId/accept"),
        headers: authHeaders(token),
      );

      print("STATUS ACCEPT = ${response.statusCode}");
      print("BODY ACCEPT = ${response.body}");

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print("ERROR ACCEPT = $e");
      return false;
    }
  }

  Future<bool> rejectPartage(int partageId, String token) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/partages-suivi/$partageId/reject"),
        headers: authHeaders(token),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  String _partageAutorisationApi(Autorisation a) {
    switch (a) {
      case Autorisation.ecriture:
        return "Ecriture";
      case Autorisation.complete:
        return "Complete";
      case Autorisation.lecture:
        return "Lecture";
    }
  }

  // Fabrice | 2026-05-05T04:56:37Z | Liste les partages GET /api/partages-suivi.
  Future<List<dynamic>> getPartagesSuivi(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/partages-suivi"),
        headers: authHeaders(token),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // Fabrice | 2026-05-05T04:47:29Z | GET /api/users/{id} nécessite un JWT valide.
  Future<Map<String, dynamic>?> getUser(int id, String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/users/$id"),
        headers: authHeaders(token),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      debugPrint("Erreur getUser: Status ${response.statusCode}");
      return null;
    } catch (e) {
      debugPrint("Exception getUser: $e");
      return null;
    }
  }
}
