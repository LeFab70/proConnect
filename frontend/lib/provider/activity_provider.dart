import 'package:flutter/material.dart';

import '../models/activity.dart';
import '../services/community_ai_service.dart';
import 'auth_provider.dart';

class DailyActivity {
  final DateTime date;
  int steps;
  int stepGoal;
  int activeMinutes;
  int caloriesBurned;

  DailyActivity({
    required this.date,
    required this.steps,
    required this.stepGoal,
    required this.activeMinutes,
    required this.caloriesBurned,
  });

  double get progressRatio {
    if (stepGoal == 0) return 0;
    return (steps / stepGoal).clamp(0.0, 1.0);
  }
}

class ActivityProvider with ChangeNotifier {
  // Initialisation par liste vide pour éviter les erreurs d'initialisation tardive
  List<DailyActivity> _weeklyHistory = [];

  bool _isLoading = true;
  String _errorMessage = "";

  final List<ActiviteIA> _activitesIA = [];
  String _currentCity = "Bathurst";

  ActivityProvider() {
    _initializeData();
  }

  // --- GETTERS ---
  List<DailyActivity> get weeklyHistory => List.unmodifiable(_weeklyHistory);

  // Sécurisé pour éviter "Bad state: No element" si la liste est vide au début
  DailyActivity get todayActivity {
    if (_weeklyHistory.isEmpty) {
      return DailyActivity(
        date: DateTime.now(),
        steps: 0,
        stepGoal: 8000,
        activeMinutes: 0,
        caloriesBurned: 0,
      );
    }
    return _weeklyHistory.last;
  }

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<ActiviteIA> get activitesIA => List.unmodifiable(_activitesIA);
  String get currentCity => _currentCity;

  // --- MÉTHODE : Initialisation des données ---
  Future<void> _initializeData() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final DateTime now = DateTime.now();

    _weeklyHistory = List.generate(7, (index) {
      final DateTime day = now.subtract(Duration(days: 6 - index));
      final bool isToday = index == 6;

      return DailyActivity(
        date: day,
        steps: isToday ? 3450 : 6000 + (index * 500) % 3000,
        stepGoal: 8000,
        activeMinutes: isToday ? 25 : 45 + (index * 10) % 30,
        caloriesBurned: isToday ? 150 : 300 + (index * 50) % 200,
      );
    });

    _isLoading = false;
    notifyListeners();
  }

  // --- MÉTHODE : Ajouter des pas ---
  Future<void> addSteps(int newSteps) async {
    if (_isLoading || _weeklyHistory.isEmpty) return;

    _weeklyHistory.last.steps += newSteps;

    // Empêcher de dépasser graphiquement l'objectif si nécessaire
    // (Optionnel : retirez la ligne suivante si vous voulez dépasser 100%)
    if (_weeklyHistory.last.steps > _weeklyHistory.last.stepGoal) {
      // _weeklyHistory.last.steps = _weeklyHistory.last.stepGoal;
    }

    notifyListeners();
  }

  // --- MÉTHODE : Modifier l'objectif de pas ---
  void updateStepGoal(int newGoal) {
    if (_isLoading || _weeklyHistory.isEmpty) return;

    _weeklyHistory.last.stepGoal = newGoal;
    notifyListeners(); // Met à jour l'UI (Dashboard, etc.)
  }

  // Fabrice | 2026-05-05T04:56:37Z | POST /api/activites/suggestions si JWT ; sinon maquette locale.
  Future<void> fetchAIActivities(
    AuthProvider auth, {
    String region = "Moncton",
  }) async {
    _isLoading = true;
    _errorMessage = "";
    _currentCity = region;
    notifyListeners();

    try {
      _activitesIA.clear();

      final token = auth.token;
      if (token != null) {
        final svc = CommunityAiService();
        final adresse = '$region, NB, Canada';
        final list = await svc.fetchSuggestions(
          token: token,
          adresse: adresse,
        );
        _activitesIA.addAll(list);
      } else {
        await Future.delayed(const Duration(milliseconds: 400));

        _activitesIA.addAll([
          ActiviteIA(
            id: 1,
            titre: "Marche santé",
            description: "Activité légère recommandée pour rester actif.",
            dateHeure: DateTime.now().add(const Duration(hours: 2)),
            lieu: "Centre-ville de $region",
            categorie: "Santé",
            scorePertinence: 0.95,
            region: region,
          ),
          ActiviteIA(
            id: 2,
            titre: "Atelier communautaire",
            description: "Rencontre sociale et activité de groupe.",
            dateHeure: DateTime.now().add(const Duration(days: 1, hours: 3)),
            lieu: "Centre communautaire de $region",
            categorie: "Social",
            scorePertinence: 0.88,
            region: region,
          ),
        ]);
      }
    } catch (e) {
      _errorMessage = "Erreur lors du chargement des activités";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
