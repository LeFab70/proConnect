import 'package:flutter/material.dart';

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

  double get progressRatio => (steps / stepGoal).clamp(0.0, 1.0);
}

class ActivityProvider with ChangeNotifier {
  late List<DailyActivity> _weeklyHistory;
  bool _isLoading = true;

  ActivityProvider() {
    _initializeData();
  }

  List<DailyActivity> get weeklyHistory => List.unmodifiable(_weeklyHistory);
  DailyActivity get todayActivity => _weeklyHistory.last;
  bool get isLoading => _isLoading;

  Future<void> _initializeData() async {
    await Future.delayed(const Duration(milliseconds: 1000));

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

  Future<void> addSteps(int newSteps) async {
    if (_isLoading) return;

    _weeklyHistory.last.steps += newSteps;
    if (_weeklyHistory.last.steps > _weeklyHistory.last.stepGoal) {
      _weeklyHistory.last.steps = _weeklyHistory.last.stepGoal;
    }

    notifyListeners();
  }
}
