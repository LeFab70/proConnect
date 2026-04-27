import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/aine.dart';

class AineService {
  final String baseUrl = "https://proconnectnb-d2bxe6embxg2e7h7.eastus2-01.azurewebsites.net";

  Future<List<Aine>> getAines(String token) async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Aine.fromJson(e)).toList();
    } else {
      throw Exception("Erreur chargement aînés");
    }
  }

  Future<bool> createAine(Map<String, dynamic> data, String token) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: json.encode(data),
    );

    return response.statusCode == 201;
  }
}