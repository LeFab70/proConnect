import 'package:http/http.dart' as http;

/// Client HTTP minimal. Renseigner [baseUrl] selon l’environnement (ex. `http://localhost:5xxx` en local).
class Api {
  Api({this.baseUrl = 'http://localhost:5000'});

  final String baseUrl;

  Future<String> getUser(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/users/$id'));
    if (response.statusCode == 200) return response.body;
    if (response.statusCode == 404) return 'Utilisateur introuvable';
    return 'Erreur: ${response.statusCode}';
  }
}
