import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TranslationService {
  // Utilisation du .env pour ne pas laisser traîner votre clé API
  static final String _apiKey = dotenv.env['GOOGLE_TRANSLATE_API_KEY'] ?? "";

  // En ajoutant les accolades {}, "lang" devient optionnel et vaut 'fr' par défaut
  static Future<String> translate(String text, {String lang = 'fr'}) async {
    if (text.isEmpty || text == "null") return text;

    final url = Uri.parse("https://translation.googleapis.com/language/translate/v2?key=$_apiKey");

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "q": text,
          "target": lang,
          "format": "text",
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data["data"]["translations"][0]["translatedText"];
      }
    } catch (e) {
      print("Erreur de traduction : $e");
    }

    return text;
  }
}