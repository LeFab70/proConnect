import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import '../models/activity.dart';

class PredictHqService {
  static const String _baseUrl = 'https://api.predicthq.com/v1/events';

  final String _apiToken = dotenv.env['PREDICT_HQ_TOKEN'] ?? '';

  // 🔥 MÉTHODE GÉNÉRIQUE PAR VILLE
  Future<List<ActiviteIA>> fetchEventsByCity(String city) async {
    try {
      final now = DateTime.now().toUtc();
      final nextWeek = now.add(const Duration(days: 7));

      final start = DateFormat("yyyy-MM-ddTHH:mm:ss").format(now);
      final end = DateFormat("yyyy-MM-ddTHH:mm:ss").format(nextWeek);

      final url = Uri.parse(
        '$_baseUrl'
        '?q=$city'
        '&active.gte=$start'
        '&active.lte=$end'
        '&category=community,festivals,performing-arts,sports,concerts'
        '&limit=20'
        '&sort=start',
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_apiToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> results = data['results'];

        return _mapAndFilter(results, city);
      } else {
        print("❌ Erreur API : ${response.statusCode}");
        print("📄 Body : ${response.body}");
        throw Exception('Erreur API PredictHQ');
      }
    } catch (e) {
      print("🔥 Erreur fetchEventsByCity : $e");
      return [];
    }
  }

  // 🔁 MÉTHODE BATHURST (compatibilité)
  Future<List<ActiviteIA>> fetchBathurstEvents() async {
    try {
      final now = DateTime.now().toUtc();
      final nextWeek = now.add(const Duration(days: 7));

      final start = DateFormat("yyyy-MM-ddTHH:mm:ss").format(now);
      final end = DateFormat("yyyy-MM-ddTHH:mm:ss").format(nextWeek);

      final double lat = 47.6177;
      final double lon = -65.6510;

      final url = Uri.parse(
        '$_baseUrl'
        '?location_filter.distance=50km'
        '&location_filter.point=$lat,$lon'
        '&category=community,festivals,performing-arts,sports,concerts'
        '&active.gte=$start'
        '&active.lte=$end'
        '&limit=20'
        '&sort=start',
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_apiToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> results = data['results'];

        return _mapAndFilter(results, "Bathurst");
      } else {
        throw Exception('Erreur API PredictHQ');
      }
    } catch (e) {
      print("🔥 Erreur Bathurst : $e");
      return [];
    }
  }

  // 🧠 MÉTHODE PRIVÉE (réutilisable)
  List<ActiviteIA> _mapAndFilter(List<dynamic> results, String city) {
    final nowLocal = DateTime.now();

    final filtered = results.where((event) {
      final eventDate = DateTime.parse(event['start']);
      return eventDate.isAfter(nowLocal);
    }).toList();

    return filtered.map((event) {
      return ActiviteIA.fromJson({
        "id": event['id'].hashCode,
        "titre": event['title'],
        "description": (event['description'] != null &&
                event['description'].toString().isNotEmpty)
            ? event['description']
            : "Événement local à $city.",
        "dateHeure": event['start'],
        "lieu": (event['entities'] != null &&
                event['entities'].isNotEmpty)
            ? event['entities'][0]['name']
            : city,
        "categorie": event['category'],
        "region": city,
        "score_pertinence": (event['rank'] ?? 50) / 100,
      });
    }).toList();
  }
}