import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import '../models/activity.dart';

class PredictHqService {
  static const String _baseUrl = 'https://api.predicthq.com/v1/events';

  final String _apiToken = dotenv.env['PREDICT_HQ_TOKEN'] ?? '';

  /// 🔍 MÉTHODE PRINCIPALE PAR VILLE
  Future<List<ActiviteIA>> fetchEventsByCity(String city) async {
    try {
      final now = DateTime.now().toUtc();
      final nextWeek = now.add(const Duration(days: 7));

      final start = DateFormat("yyyy-MM-ddTHH:mm:ss").format(now);
      final end = DateFormat("yyyy-MM-ddTHH:mm:ss").format(nextWeek);

      final uri = Uri.parse(
        '$_baseUrl'
        '?q=$city'
        '&active.gte=$start'
        '&active.lte=$end'
        '&category=community,festivals,performing-arts,sports,concerts'
        '&limit=20'
        '&sort=start',
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_apiToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? [];

        return _mapAndFilter(results, city);
      } else {
        debugPrint("❌ Erreur API : ${response.statusCode}");
        debugPrint("📄 Body : ${response.body}");
        throw Exception('Erreur API PredictHQ');
      }
    } catch (e) {
      debugPrint("🔥 Erreur fetchEventsByCity : $e");
      return [];
    }
  }

  /// 📍 MÉTHODE OPTIONNELLE (exemple géolocalisation fixe)
  Future<List<ActiviteIA>> fetchBathurstEvents() async {
    try {
      final now = DateTime.now().toUtc();
      final nextWeek = now.add(const Duration(days: 30));

      final start = DateFormat("yyyy-MM-ddTHH:mm:ss").format(now);
      final end = DateFormat("yyyy-MM-ddTHH:mm:ss").format(nextWeek);

      final double lat = 47.6177;
      final double lon = -65.6510;

      final uri = Uri.parse(
        '$_baseUrl'
        '?location_filter.distance=50km'
        '&location_filter.point=$lat,$lon'
        '&category=community,conferences,expos,festivals,performing-arts,concerts,sports,school-holidays,public-holidays,observances,academic'
        '&active.gte=$start'
        '&active.lte=$end'
        '&limit=20'
        '&sort=start',
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_apiToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? [];

        return _mapAndFilter(results, "Bathurst");
      } else {
        throw Exception('Erreur API PredictHQ');
      }
    } catch (e) {
      debugPrint(" Erreur Bathurst : $e");
      return [];
    }
  }

  // TRANSFORMATION → ActiviteIA
  List<ActiviteIA> _mapAndFilter(List<dynamic> results, String city) {
    final nowLocal = DateTime.now();

    final filtered = results.where((event) {
      try {
        final eventDate = DateTime.parse(event['start']);
        return eventDate.isAfter(nowLocal);
      } catch (_) {
        return false;
      }
    }).toList();

    return filtered.map((event) {
      return ActiviteIA.fromJson({
        "id": event['id'].hashCode,
        "titre": event['title'],
        "description":
            (event['description'] != null &&
                event['description'].toString().isNotEmpty)
            ? event['description']
            : "Événement local à $city.",
        "dateHeure": event['start'],
        "lieu": (event['entities'] != null && event['entities'].isNotEmpty)
            ? event['entities'][0]['name']
            : city,
        "categorie": event['category'],
        "region": city,
        "score_pertinence": (event['rank'] ?? 50) / 100,
        "source": "predicthq",
      });
    }).toList();
  }
}
