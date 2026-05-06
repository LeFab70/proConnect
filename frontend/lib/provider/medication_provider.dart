import 'package:flutter/material.dart';

import '../models/medication.dart';
import '../services/medication_service.dart';
import 'auth_provider.dart';

class MedicationProvider with ChangeNotifier {
  final MedicationService _service = MedicationService();

  final List<Medication> _medications = [];
  final Map<String, bool> _takenLocal = {};

  bool _isLoading = false;
  String _error = '';

  bool get isLoading => _isLoading;
  String get error => _error;

  Medication _withTakenOverlay(Medication m) {
    final local = _takenLocal[m.id];
    if (local == null) return m;
    return m.copyWith(isTaken: local);
  }

  List<Medication> get medications =>
      List.unmodifiable(_medications.map(_withTakenOverlay));

  List<Medication> get activeMedications =>
      medications.where((m) => m.isActive && !m.isDeleted).toList();

  Medication? getMedicationById(String id) {
    try {
      return _withTakenOverlay(_medications.firstWhere((m) => m.id == id));
    } catch (_) {
      return null;
    }
  }

  double get adherenceRate {
    final validMeds = _medications.where((m) => !m.isDeleted).toList();
    if (validMeds.isEmpty) return 0.0;
    final takenCount =
        validMeds.where((m) => _withTakenOverlay(m).isTaken).length;
    return takenCount / validMeds.length;
  }

  // Fabrice | 2026-05-05T04:56:37Z | Rafraîchit depuis GET /api/medicaments.
  Future<void> fetchMedications(AuthProvider auth) async {
    if (auth.token == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final list = await _service.getMedicaments(auth.token!);
      _medications
        ..clear()
        ..addAll(list);
      _error = '';
    } catch (_) {
      _error = 'Erreur lors du chargement des médicaments';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fabrice | 2026-05-05T04:56:37Z | État « pris » uniquement local (non persisté API).
  void toggleTaken(String id) {
    Medication? med;
    for (final m in _medications) {
      if (m.id == id) {
        med = m;
        break;
      }
    }
    if (med == null) return;

    final current = _withTakenOverlay(med).isTaken;
    _takenLocal[id] = !current;
    notifyListeners();
  }

  // Fabrice | 2026-05-05T04:56:37Z | PUT isActive si JWT ; sinon mise à jour locale.
  Future<bool> toggleActive(String id, bool value, AuthProvider auth) async {
    final index = _medications.indexWhere((m) => m.id == id);
    if (index == -1) return false;

    final token = auth.token;
    final mid = int.tryParse(id);

    if (token != null && mid != null) {
      final cur = _medications[index];
      final updated = cur.copyWith(isActive: value);
      final ok = await _service.updateMedicament(mid, updated.toJson(), token);
      if (ok) {
        _medications[index] = updated;
        notifyListeners();
        return true;
      }
      _error = 'Synchronisation impossible (vérifie les droits API)';
      notifyListeners();
      return false;
    }

    _medications[index] = _medications[index].copyWith(isActive: value);
    notifyListeners();
    return true;
  }

  void renewMedication(String id) {
    _takenLocal[id] = false;
    notifyListeners();
  }

  Future<bool> addMedication(
    String name,
    String marque,
    String dosage,
    List<String> schedules, {
    String? urlPhoto,
    int aineId = 1,
    bool isActive = false,
    AuthProvider? auth,
  }) async {
    try {
      final cleanSchedules = _cleanSchedules(schedules);

      final body = {
        'nom': name,
        'marque': marque,
        'dosage': dosage,
        'frequence': cleanSchedules.join(', '),
        'aineId': aineId,
        if (urlPhoto != null && urlPhoto.trim().isNotEmpty)
          'urlPhoto': urlPhoto.trim(),
        'isActive': isActive,
      };

      final token = auth?.token;
      if (token != null) {
        final ok = await _service.createMedicament(body, token);
        if (ok) {
          await fetchMedications(auth!);
          return true;
        }
        _error = 'Création refusée (droits admin requis côté API)';
        notifyListeners();
        return false;
      }

      final newMed = Medication(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        marque: marque,
        dosage: dosage,
        schedules: cleanSchedules,
        urlPhoto: urlPhoto,
        aineId: aineId,
        isTaken: false,
        isActive: isActive,
        isDeleted: false,
      );
      _medications.add(newMed);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateMedication(
    String id,
    String name,
    String marque,
    String dosage,
    List<String> schedules, {
    String? urlPhoto,
    int? aineId,
    bool? isActive,
    AuthProvider? auth,
  }) async {
    try {
      final index = _medications.indexWhere((m) => m.id == id);
      if (index == -1) return false;

      final current = _medications[index];
      final cleanSchedules = _cleanSchedules(schedules);

      final next = current.copyWith(
        name: name,
        marque: marque,
        dosage: dosage,
        schedules: cleanSchedules,
        urlPhoto: urlPhoto ?? current.urlPhoto,
        aineId: aineId ?? current.aineId,
        isActive: isActive ?? current.isActive,
      );

      final token = auth?.token;
      final mid = int.tryParse(id);

      if (token != null && mid != null) {
        final ok =
            await _service.updateMedicament(mid, next.toJson(), token);
        if (ok) {
          _medications[index] = next;
          notifyListeners();
          return true;
        }
        _error = 'Mise à jour refusée (droits admin requis côté API)';
        notifyListeners();
        return false;
      }

      _medications[index] = next;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteMedication(String id, {AuthProvider? auth}) async {
    try {
      final token = auth?.token;
      final mid = int.tryParse(id);

      if (token != null && mid != null) {
        final ok = await _service.deleteMedicament(mid, token);
        if (ok) {
          _takenLocal.remove(id);
          if (auth != null) {
            await fetchMedications(auth);
          } else {
            notifyListeners();
          }
          return true;
        }
        _error = 'Suppression refusée (droits admin requis côté API)';
        notifyListeners();
        return false;
      }

      final initialLength = _medications.length;
      _medications.removeWhere((m) => m.id == id);
      _takenLocal.remove(id);

      if (_medications.length < initialLength) {
        notifyListeners();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  List<String> _cleanSchedules(List<String> schedules) {
    final unique = schedules
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();

    unique.sort();
    return unique;
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  void reset() {
    _medications.clear();
    _takenLocal.clear();
    _error = '';
    notifyListeners();
  }
}
