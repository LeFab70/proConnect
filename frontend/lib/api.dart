import 'dart:convert';
import 'package:http/http.dart' as http;

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

      print('LOGIN STATUS: ${response.statusCode}');
      print('LOGIN BODY: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'success': true,
          'token': data['accessToken'],
          'role': data['role'] ?? 'AINE',
          'firstName': data['firstName'] ?? email.split('@')[0],
          'userId': data['userId'],
          'profilePicture': data['profilePicture'],
          'nbDemandes': data['nbDemandes'] ?? 0,
        };
      }

      return {'success': false, 'message': 'Email ou mot de passe incorrect'};
    } catch (e) {
      print('===================');
      print('LOGIN ERROR');
      print(e);
      print('===================');

      return {'success': false, 'message': 'Erreur de connexion au serveur'};
    }
  }

  Future<String> getUser(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/users/$id'));

    if (response.statusCode == 200) return response.body;
    if (response.statusCode == 404) return 'Utilisateur introuvable';

    return 'Erreur: ${response.statusCode}';
  }
}
