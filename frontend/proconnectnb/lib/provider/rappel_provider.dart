import 'package:flutter/material.dart';
import '../models/rappel.dart';
import '../../services/notification_service.dart';

class RappelProvider with ChangeNotifier {
  final List<Rappel> _rappels = [];

  List<Rappel> get rappels => List.unmodifiable(_rappels);

  List<Rappel> get rappelsActifs {
    return _rappels.where((r) => r.actif).toList()..sort(
      (a, b) => a.dateHeureNotification.compareTo(b.dateHeureNotification),
    );
  }

  List<Rappel> get rappelsDuJour {
    final today = DateTime.now();

    return _rappels.where((r) {
      return r.actif &&
          r.dateHeureNotification.year == today.year &&
          r.dateHeureNotification.month == today.month &&
          r.dateHeureNotification.day == today.day;
    }).toList()..sort(
      (a, b) => a.dateHeureNotification.compareTo(b.dateHeureNotification),
    );
  }

  Future<bool> addRappel(Rappel rappel) async {
    final existeDeja = _rappels.any(
      (r) =>
          r.medicamentId == rappel.medicamentId &&
          r.heureDebut == rappel.heureDebut &&
          r.dateHeurePrise == rappel.dateHeurePrise,
    );

    if (existeDeja) return false;

    _rappels.add(rappel);
    _sort();
    notifyListeners();
    return true;
  }

  Future<void> deleteByGroup(String groupeId) async {
    _rappels.removeWhere((r) => r.groupeId == groupeId);
    notifyListeners();
  }

  Future<bool> updateRappel(Rappel rappel) async {
    final index = _rappels.indexWhere((r) => r.id == rappel.id);

    if (index == -1) return false;

    _rappels[index] = rappel;
    _sort();
    notifyListeners();

    return true;
  }

  Future<bool> deleteRappel(int id) async {
    final initialLength = _rappels.length;

    _rappels.removeWhere((r) => r.id == id);

    if (_rappels.length < initialLength) {
      notifyListeners();
      return true;
    }
    await NotificationService.cancelNotification(id);
    return false;
  }

  Future<bool> deleteRappelByMedicamentId(int medicamentId) async {
    final initialLength = _rappels.length;

    _rappels.removeWhere((r) => r.medicamentId == medicamentId);

    if (_rappels.length < initialLength) {
      notifyListeners();
      return true;
    }

    return false;
  }

  Future<bool> deleteRappelByRendezVousMedicalId(
    int rendezVousMedicalId,
  ) async {
    final initialLength = _rappels.length;

    _rappels.removeWhere((r) => r.rendezVousMedicalId == rendezVousMedicalId);

    if (_rappels.length < initialLength) {
      notifyListeners();
      return true;
    }

    return false;
  }

  Future<bool> deleteRappelByMedicamentIdAndHeure(
    int medicamentId,
    String heureDebut,
  ) async {
    final initialLength = _rappels.length;

    _rappels.removeWhere(
      (r) => r.medicamentId == medicamentId && r.heureDebut == heureDebut,
    );

    if (_rappels.length < initialLength) {
      notifyListeners();
      return true;
    }

    return false;
  }

  void toggleRappel(int id, bool value) {
    final index = _rappels.indexWhere((r) => r.id == id);

    if (index == -1) return;

    final old = _rappels[index];

    _rappels[index] = old.copyWith(actif: value);

    notifyListeners();
  }

  void setRappels(List<Rappel> rappels) {
    _rappels
      ..clear()
      ..addAll(rappels);

    _sort();
    notifyListeners();
  }

  void clear() {
    _rappels.clear();
    notifyListeners();
  }

  void _sort() {
    _rappels.sort(
      (a, b) => a.dateHeureNotification.compareTo(b.dateHeureNotification),
    );
  }
}
