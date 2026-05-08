import 'package:flutter/material.dart';

import '../models/rappel.dart';
import '../services/rappel_service.dart';
import '../services/notification_service.dart';
import 'auth_provider.dart';

class RappelProvider with ChangeNotifier {
  final RappelService _service = RappelService();

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

  Future<void> fetchRappels(AuthProvider auth) async {
    if (auth.token == null || auth.token!.isEmpty) return;

    try {
      final list = await _service.getRappels(auth.token!);

      _rappels
        ..clear()
        ..addAll(list);

      _sort();
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur fetchRappels: $e');
    }
  }

  Future<bool> addRappel(Rappel rappel, AuthProvider auth) async {
    final existeDeja = _rappels.any(
      (r) =>
          r.medicamentId == rappel.medicamentId &&
          r.heureDebut == rappel.heureDebut &&
          r.dateHeurePrise == rappel.dateHeurePrise,
    );

    if (existeDeja) return false;

    final token = auth.token;

    if (token != null && token.isNotEmpty) {
      final id = await _service.createRappel(rappel, token);

      debugPrint("CREATE RAPPEL ID: $id");

      if (id != null) {
        final saved = rappel.copyWith(id: id);

        _rappels.add(saved);
        _sort();
        notifyListeners();

        await fetchRappels(auth);

        return true;
      }
    }

    _rappels.add(rappel);
    _sort();
    notifyListeners();

    return true;
  }

  Future<void> deleteByGroup(String groupeId) async {
    _rappels.removeWhere((r) => r.groupeId == groupeId);
    notifyListeners();
  }

  Future<bool> updateRappel(Rappel rappel, AuthProvider auth) async {
    final token = auth.token;

    if (token != null && token.isNotEmpty && rappel.id > 0) {
      final ok = await _service.updateRappel(rappel.id, rappel, token);

      if (ok) {
        final index = _rappels.indexWhere((r) => r.id == rappel.id);

        if (index != -1) {
          _rappels[index] = rappel;
          _sort();
          notifyListeners();
        }

        await fetchRappels(auth);

        return true;
      }
    }

    final index = _rappels.indexWhere((r) => r.id == rappel.id);

    if (index == -1) return false;

    _rappels[index] = rappel;
    _sort();
    notifyListeners();

    return true;
  }

  Future<bool> deleteRappel(int id, AuthProvider auth) async {
    await NotificationService.cancelNotification(id);

    final token = auth.token;

    if (token != null && token.isNotEmpty && id > 0) {
      final ok = await _service.deleteRappel(id, token);

      if (ok) {
        _rappels.removeWhere((r) => r.id == id);
        notifyListeners();
        return true;
      }
    }

    final initialLength = _rappels.length;

    _rappels.removeWhere((r) => r.id == id);

    if (_rappels.length < initialLength) {
      notifyListeners();
      return true;
    }

    return false;
  }

  Future<bool> deleteRappelByMedicamentId(
    int medicamentId,
    AuthProvider auth,
  ) async {
    final toRemove = _rappels
        .where((r) => r.medicamentId == medicamentId)
        .toList();

    for (final r in toRemove) {
      await deleteRappel(r.id, auth);
    }

    return toRemove.isNotEmpty;
  }

  Future<bool> deleteRappelByRendezVousMedicalId(
    int rendezVousMedicalId,
    AuthProvider auth,
  ) async {
    final toRemove = _rappels
        .where((r) => r.rendezVousMedicalId == rendezVousMedicalId)
        .toList();

    for (final r in toRemove) {
      await deleteRappel(r.id, auth);
    }

    return toRemove.isNotEmpty;
  }

  Future<bool> deleteRappelByMedicamentIdAndHeure(
    int medicamentId,
    String heureDebut,
    AuthProvider auth,
  ) async {
    final toRemove = _rappels
        .where(
          (r) => r.medicamentId == medicamentId && r.heureDebut == heureDebut,
        )
        .toList();

    for (final r in toRemove) {
      await deleteRappel(r.id, auth);
    }

    return toRemove.isNotEmpty;
  }

  Future<void> toggleRappel(int id, bool value, AuthProvider auth) async {
    final index = _rappels.indexWhere((r) => r.id == id);

    if (index == -1) return;

    final old = _rappels[index];
    final next = old.copyWith(actif: value);

    await updateRappel(next, auth);
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
