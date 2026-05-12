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

  static const _timeout = Duration(seconds: 15);

  Future<http.Response> _get(Uri uri, {Map<String, String>? headers}) =>
      http.get(uri, headers: headers).timeout(_timeout);

  Future<http.Response> _post(Uri uri, {Map<String, String>? headers, Object? body}) =>
      http.post(uri, headers: headers, body: body).timeout(_timeout);

  Future<http.Response> _put(Uri uri, {Map<String, String>? headers, Object? body}) =>
      http.put(uri, headers: headers, body: body).timeout(_timeout);

  Future<http.Response> _delete(Uri uri, {Map<String, String>? headers}) =>
      http.delete(uri, headers: headers).timeout(_timeout);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _post(
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

  Future<Map<String, dynamic>> _fetchLoginProfile(
    String token,
    String emailLower,
  ) async {
    int? userId;
    String? meEmail;

    final meResp = await _get(
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

    final ainesResp = await _get(
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
            "firstName": m["prenom"]?.toString() ?? matchEmail.split("@").first,
            "lastName": m["nom"]?.toString() ?? "",
            "telephone": m["telephone"]?.toString() ?? "",
            "dateNaissance": m["dateNaissance"]?.toString(),
            "role": "AINE",
          };
        }
      }
    }

    final paResp = await _get(
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
            "firstName": m["prenom"]?.toString() ?? matchEmail.split("@").first,
            "lastName": m["nom"]?.toString() ?? "",
            "telephone": m["telephone"]?.toString() ?? "",
            "role": "AIDANT",
          };
        }
      }
    }

    if (userId != null) {
      final uResp = await _get(
        Uri.parse("$baseUrl/api/users/$userId"),
        headers: authHeaders(token),
      );
      if (uResp.statusCode == 200) {
        final u = jsonDecode(uResp.body) as Map<String, dynamic>;
        return {
          "userId": userId,
          "firstName": u["prenom"]?.toString() ?? matchEmail.split("@").first,
          "lastName": u["nom"]?.toString() ?? "",
          "telephone": u["telephone"]?.toString() ?? "",
          "role": "AIDANT",
        };
      }
    }

    return {
      "userId": userId,
      "firstName": matchEmail.split("@").first,
      "lastName": "",
      "telephone": "",
      "role": "AIDANT",
    };
  }

  int? _parseId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  Future<Map<String, dynamic>> register({
    required String nom,
    required String prenom,
    required String telephone,
    required String email,
    required String password,
    String? role,
    DateTime? dateNaissance,
    Map<String, dynamic>? adresse,
  }) async {
    try {
      final requestBody = <String, dynamic>{
        "nom": nom,
        "prenom": prenom,
        "telephone": telephone,
        "email": email.trim(),
        "password": password,
        if (role != null && role.trim().isNotEmpty) "role": role.trim(),
        if (dateNaissance != null)
          "dateNaissance":
              "${dateNaissance.year.toString().padLeft(4, '0')}-${dateNaissance.month.toString().padLeft(2, '0')}-${dateNaissance.day.toString().padLeft(2, '0')}",
        if (adresse != null) "adresse": adresse,
      };
      final response = await _post(
        Uri.parse("$baseUrl/api/auth/register"),
        headers: headers(),
        body: jsonEncode(requestBody),
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

  Future<List<dynamic>> getAines(String token) async {
    try {
      final response = await _get(
        Uri.parse("$baseUrl/api/aines"),
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

  Future<bool> registerAine({
    required Map<String, dynamic> data,
    required String token,
  }) async {
    try {
      final response = await _post(
        Uri.parse("$baseUrl/api/aines"),
        headers: authHeaders(token),
        body: jsonEncode(data),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  // ======================================================
  // PROCHES AIDANTS (Caregivers)
  // ======================================================

  Future<List<dynamic>> getCaregivers(String token) async {
    try {
      final response = await _get(
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
      final response = await _post(
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
      final response = await _post(
        Uri.parse("$baseUrl${endpoint.startsWith('/') ? '' : '/'}$endpoint"),
        headers: authHeaders(token),
        body: jsonEncode(body),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<bool> put(
    String endpoint,
    Map<String, dynamic> body,
    String token,
  ) async {
    try {
      final response = await _put(
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
      final response = await _delete(
        Uri.parse("$baseUrl${endpoint.startsWith('/') ? '' : '/'}$endpoint"),
        headers: authHeaders(token),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  // ======================================================
  // AUTRES (Partages, Users)
  // ======================================================

  Future<bool> upsertPartage(PartageSuivi partage, String token) async {
    try {
      final response = await _post(
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
      final response = await _post(
        Uri.parse("$baseUrl/api/partages-suivi/$partageId/accept"),
        headers: authHeaders(token),
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rejectPartage(int partageId, String token) async {
    try {
      final response = await _post(
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

  Future<List<dynamic>> getPartagesSuivi(String token) async {
    try {
      final response = await _get(
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

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String token,
  }) async {
    try {
      final response = await _post(
        Uri.parse("$baseUrl/api/auth/change-password"),
        headers: authHeaders(token),
        body: jsonEncode({
          "currentPassword": currentPassword,
          "newPassword": newPassword,
        }),
      );
      return response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateProfile({
    required String prenom,
    required String nom,
    required String telephone,
    required String token,
  }) async {
    try {
      final response = await _put(
        Uri.parse("$baseUrl/api/auth/profile"),
        headers: authHeaders(token),
        body: jsonEncode({
          "prenom": prenom,
          "nom": nom,
          "telephone": telephone,
        }),
      );
      return response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUser(int id, String token) async {
    try {
      final response = await _get(
        Uri.parse("$baseUrl/api/users/$id"),
        headers: authHeaders(token),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
