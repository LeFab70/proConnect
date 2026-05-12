import 'dart:async';

import 'package:flutter/material.dart';

import '../models/medication.dart';
import '../services/firebase_demo_sync_service.dart';
import '../services/medication_service.dart';
import '../services/notification_service.dart';
import 'auth_provider.dart';

class MedicationProvider with ChangeNotifier {
  final MedicationService _service = MedicationService();

  final List<Medication> _medications = [];

  final Map<String, bool> _takenLocal = {};
  final Map<String, String> _statusLocal = {};
  final Map<String, DateTime?> _lastTakenAtLocal = {};
  final Map<String, DateTime?> _missedAtLocal = {};
  final Map<String, Timer> _monitoringTimers = {};

  Timer? _midnightTimer;

  bool _isLoading = false;
  String _error = '';

  bool get isLoading => _isLoading;
  String get error => _error;

  Medication _withOverlay(Medication m) {
    return m.copyWith(
      isTaken: _takenLocal[m.id] ?? m.isTaken,
      status: _statusLocal[m.id] ?? m.status,
      lastTakenAt: _lastTakenAtLocal[m.id] ?? m.lastTakenAt,
      missedAt: _missedAtLocal[m.id] ?? m.missedAt,
    );
  }

  List<Medication> get medications =>
      List.unmodifiable(_medications.map(_withOverlay));

  List<Medication> get activeMedications =>
      medications.where((m) => m.isActive && !m.isDeleted).toList();

  List<Medication> get pendingMedications =>
      medications.where((m) => m.status == 'enAttente').toList();

  List<Medication> get takenMedications =>
      medications.where((m) => m.status == 'pris').toList();

  List<Medication> get missedMedications =>
      medications.where((m) => m.status == 'nonPris').toList();

  Medication? getMedicationById(String id) {
    try {
      return _withOverlay(_medications.firstWhere((m) => m.id == id));
    } catch (_) {
      return null;
    }
  }

  double get adherenceRate {
    final validMeds = medications
        .where((m) => m.isActive && !m.isDeleted)
        .toList();

    if (validMeds.isEmpty) return 0.0;

    final takenCount = validMeds.where((m) => m.status == 'pris').length;
    return takenCount / validMeds.length;
  }

  Future<void> fetchMedications(AuthProvider auth) async {
    if (auth.token == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final list = await _service.getMedicaments(auth.token!);

      _medications
        ..clear()
        ..addAll(list);

      for (final med in _medications) {
        final demoStatus = await FirebaseDemoSyncService.getMedicationStatus(
          med.id,
        );

        if (demoStatus != null) {
          _statusLocal[med.id] = demoStatus;
          _takenLocal[med.id] = demoStatus == 'pris';
        }
      }

      _error = '';
      _scheduleMidnightReset();
    } catch (_) {
      _error = 'Erreur lors du chargement des médicaments';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleTaken(String id, {AuthProvider? auth}) async {
    final index = _medications.indexWhere((m) => m.id == id);
    if (index == -1) return;

    final med = _withOverlay(_medications[index]);
    final current = med.isTaken;

    final bool newIsTaken = !current;
    final String newStatus = newIsTaken ? 'pris' : 'enAttente';
    final DateTime? nowTaken = newIsTaken ? DateTime.now() : null;

    _takenLocal[id] = newIsTaken;
    _statusLocal[id] = newStatus;
    _lastTakenAtLocal[id] = nowTaken;
    _missedAtLocal[id] = null;

    debugPrint("FIREBASE WRITE START");

    await FirebaseDemoSyncService.saveMedicationStatus(
      medicationId: id,
      status: newStatus,
    );

    debugPrint("FIREBASE WRITE DONE");

    if (newIsTaken) {
      _cancelMonitoring(id);
      await NotificationService.cancelMedicationNotifications(id);
    } else {
      _startMedicationMonitoring(id, med.name);
    }

    notifyListeners();

    final token = auth?.token;
    final mid = int.tryParse(id);

    if (token == null || token.isEmpty || mid == null) {
      return;
    }

    final updated = _medications[index].copyWith(
      isTaken: newIsTaken,
      status: newStatus,
      lastTakenAt: nowTaken,
      missedAt: null,
    );

    final ok = await _service.updateMedicament(mid, updated.toJson(), token);

    if (ok) {
      _medications[index] = updated;
      _error = '';
      notifyListeners();
    } else {
      _error = "Impossible de synchroniser le statut du médicament";
      notifyListeners();
    }
  }

  void _startMedicationMonitoring(String medicationId, String medicationName) {
    _cancelMonitoring(medicationId);

    int elapsedMinutes = 0;

    _monitoringTimers[medicationId] = Timer.periodic(const Duration(minutes: 10), (
      timer,
    ) async {
      elapsedMinutes += 10;

      final med = getMedicationById(medicationId);

      if (med == null) {
        timer.cancel();
        return;
      }

      if (med.isTaken || med.status == 'pris') {
        timer.cancel();
        return;
      }

      await NotificationService.showMedicationReminder(
        id: medicationId.hashCode + elapsedMinutes,
        title: 'Médicament non confirmé',
        body:
            'Le médicament "$medicationName" n’a toujours pas été marqué comme pris.',
      );

      if (elapsedMinutes >= 60) {
        _takenLocal[medicationId] = false;
        _statusLocal[medicationId] = 'nonPris';
        _missedAtLocal[medicationId] = DateTime.now();

        await FirebaseDemoSyncService.saveMedicationStatus(
          medicationId: medicationId,
          status: 'nonPris',
        );

        timer.cancel();
        notifyListeners();

        await NotificationService.showMedicationReminder(
          id: medicationId.hashCode + 999,
          title: 'Médicament non pris',
          body:
              'Le médicament "$medicationName" est maintenant marqué comme NON PRIS.',
        );
      }

      notifyListeners();
    });
  }

  void _cancelMonitoring(String medicationId) {
    if (_monitoringTimers.containsKey(medicationId)) {
      _monitoringTimers[medicationId]?.cancel();
      _monitoringTimers.remove(medicationId);
    }
  }

  void _scheduleMidnightReset() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final delay = nextMidnight.difference(now);
    _midnightTimer = Timer(delay, _resetDailyStatus);
  }

  void _resetDailyStatus() {
    _takenLocal.clear();
    _statusLocal.clear();
    _lastTakenAtLocal.clear();
    _missedAtLocal.clear();

    for (final timer in _monitoringTimers.values) {
      timer.cancel();
    }

    _monitoringTimers.clear();
    notifyListeners();
    _scheduleMidnightReset();
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
        final ok = await _service.updateMedicament(mid, next.toJson(), token);

        if (ok) {
          _medications[index] = next;
          notifyListeners();
          return true;
        }

        _error = 'Mise à jour refusée côté API';
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
          _statusLocal.remove(id);
          _lastTakenAtLocal.remove(id);
          _missedAtLocal.remove(id);
          _cancelMonitoring(id);

          await FirebaseDemoSyncService.deleteMedicationStatus(
            medicationId: id,
          );

          if (auth != null) {
            await fetchMedications(auth);
          } else {
            notifyListeners();
          }

          return true;
        }

        _error = 'Suppression refusée côté API';
        notifyListeners();
        return false;
      }

      final initialLength = _medications.length;

      _medications.removeWhere((m) => m.id == id);

      _takenLocal.remove(id);
      _statusLocal.remove(id);
      _lastTakenAtLocal.remove(id);
      _missedAtLocal.remove(id);
      _cancelMonitoring(id);

      await FirebaseDemoSyncService.deleteMedicationStatus(medicationId: id);

      if (_medications.length < initialLength) {
        notifyListeners();
        return true;
      }

      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> toggleActive(String id, bool value, AuthProvider auth) async {
    final index = _medications.indexWhere((m) => m.id == id);
    if (index == -1) return false;

    final token = auth.token;
    final mid = int.tryParse(id);

    if (token != null && token.isNotEmpty && mid != null) {
      final cur = _medications[index];
      final updated = cur.copyWith(isActive: value);

      final ok = await _service.updateMedicament(mid, updated.toJson(), token);

      if (ok) {
        _medications[index] = updated;

        if (value) {
          _statusLocal[id] = 'enAttente';
          _takenLocal[id] = false;
          _missedAtLocal[id] = null;
          _lastTakenAtLocal[id] = null;

          await FirebaseDemoSyncService.saveMedicationStatus(
            medicationId: id,
            status: 'enAttente',
          );

          _startMedicationMonitoring(id, updated.name);
        } else {
          _cancelMonitoring(id);
          _statusLocal.remove(id);
          _takenLocal.remove(id);
          _missedAtLocal.remove(id);
          _lastTakenAtLocal.remove(id);

          await FirebaseDemoSyncService.saveMedicationStatus(
            medicationId: id,
            status: 'inactif',
          );

          await NotificationService.cancelMedicationNotifications(id);
        }

        notifyListeners();
        return true;
      }

      _error = 'Synchronisation impossible';
      notifyListeners();
      return false;
    }

    _medications[index] = _medications[index].copyWith(isActive: value);

    if (value) {
      _statusLocal[id] = 'enAttente';
      _takenLocal[id] = false;
      _missedAtLocal[id] = null;
      _lastTakenAtLocal[id] = null;

      await FirebaseDemoSyncService.saveMedicationStatus(
        medicationId: id,
        status: 'enAttente',
      );

      _startMedicationMonitoring(id, _medications[index].name);
    } else {
      _cancelMonitoring(id);
      _statusLocal.remove(id);
      _takenLocal.remove(id);
      _missedAtLocal.remove(id);
      _lastTakenAtLocal.remove(id);

      await FirebaseDemoSyncService.saveMedicationStatus(
        medicationId: id,
        status: 'inactif',
      );
    }

    notifyListeners();
    return true;
  }

  void renewMedication(String id) {
    _takenLocal[id] = false;
    _statusLocal[id] = 'enAttente';
    _lastTakenAtLocal[id] = null;
    _missedAtLocal[id] = null;

    FirebaseDemoSyncService.saveMedicationStatus(
      medicationId: id,
      status: 'enAttente',
    );

    final med = getMedicationById(id);

    if (med != null) {
      _startMedicationMonitoring(id, med.name);
    }

    notifyListeners();
  }

  Future<bool> addMedication(
    String name,
    String marque,
    String dosage,
    List<String> schedules, {
    String? urlPhoto,
    int aineId = 0,
    bool isActive = false,
    AuthProvider? auth,
  }) async {
    try {
      final cleanSchedules = _cleanSchedules(schedules);

      if (aineId <= 0) {
        _error = 'Aucun aîné sélectionné';
        notifyListeners();
        return false;
      }

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

      if (token != null && token.isNotEmpty) {
        final ok = await _service.createMedicament(body, token);

        if (ok) {
          await fetchMedications(auth!);
          return true;
        }

        _error = 'Création refusée côté API';
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
        status: 'enAttente',
      );

      _medications.add(newMed);
      notifyListeners();
      return true;
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
    _midnightTimer?.cancel();
    _midnightTimer = null;

    for (final timer in _monitoringTimers.values) {
      timer.cancel();
    }

    _monitoringTimers.clear();
    _medications.clear();
    _takenLocal.clear();
    _statusLocal.clear();
    _lastTakenAtLocal.clear();
    _missedAtLocal.clear();
    _error = '';

    notifyListeners();
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();

    for (final timer in _monitoringTimers.values) {
      timer.cancel();
    }

    super.dispose();
  }
}
