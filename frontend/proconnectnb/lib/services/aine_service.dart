import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/aine.dart';
import 'secrets.dart';

class AineService {
  final String baseUrl =
      "https://proconnectnb-d2bxe6embxg2e7h7.eastus2-01.azurewebsites.net";

  Map<String, String> authHeaders(String token) {
    return {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
      "x-api-key": Secrets.apiKey,
    };
  }

  Future<List<Aine>> getAines(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/Aines"),
      headers: authHeaders(token),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Aine.fromJson(e)).toList();
    } else {
      throw Exception("Erreur chargement aînés");
    }
  }

  Future<bool> createAine(Map<String, dynamic> data, String token) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/Aines"),
      headers: authHeaders(token),
      body: jsonEncode(data),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> updateAine(
    int id,
    Map<String, dynamic> data,
    String token,
  ) async {
    final response = await http.put(
      Uri.parse("$baseUrl/api/Aines/$id"),
      headers: authHeaders(token),
      body: jsonEncode(data),
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<bool> deleteAine(int id, String token) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/api/Aines/$id"),
        headers: authHeaders(token),
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}
