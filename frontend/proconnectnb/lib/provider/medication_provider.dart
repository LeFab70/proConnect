import 'package:flutter/material.dart';
import '../models/medication.dart';

class MedicationProvider with ChangeNotifier {
  final List<Medication> _medications = [
    Medication(
      id: '1',
      name: 'Amoxicilline',
      marque: 'Sandoz',
      dosage: '500mg',
      schedules: ['08:00', '14:00', '20:00'],
      urlPhoto: null,
      aineId: 1,
      isTaken: true,
      isActive: true,
    ),
    Medication(
      id: '2',
      name: 'Lisinopril',
      marque: 'Generique',
      dosage: '10mg',
      schedules: ['20:00'],
      urlPhoto: null,
      aineId: 1,
      isTaken: false,
      isActive: false,
    ),
  ];

  List<Medication> get medications => List.unmodifiable(_medications);

  List<Medication> get activeMedications =>
      _medications.where((m) => m.isActive && !m.isDeleted).toList();

  Medication? getMedicationById(String id) {
    try {
      return _medications.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  double get adherenceRate {
    final validMeds = _medications.where((m) => !m.isDeleted).toList();

    if (validMeds.isEmpty) return 0.0;

    final takenCount = validMeds.where((m) => m.isTaken).length;
    return takenCount / validMeds.length;
  }

  void toggleTaken(String id) {
    final index = _medications.indexWhere((m) => m.id == id);

    if (index != -1) {
      final current = _medications[index];
      _medications[index] = current.copyWith(isTaken: !current.isTaken);
      notifyListeners();
    }
  }

  void toggleActive(String id, bool value) {
    final index = _medications.indexWhere((m) => m.id == id);

    if (index != -1) {
      final current = _medications[index];
      _medications[index] = current.copyWith(isActive: value);
      notifyListeners();
    }
  }

  void renewMedication(String id) {
    final index = _medications.indexWhere((m) => m.id == id);

    if (index != -1) {
      final current = _medications[index];
      _medications[index] = current.copyWith(isTaken: false);
      notifyListeners();
    }
  }

  Future<bool> addMedication(
    String name,
    String marque,
    String dosage,
    List<String> schedules, {
    String? urlPhoto,
    int aineId = 1,
    bool isActive = false,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final cleanSchedules = _cleanSchedules(schedules);

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
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _medications.indexWhere((m) => m.id == id);

      if (index == -1) return false;

      final current = _medications[index];

      _medications[index] = current.copyWith(
        name: name,
        marque: marque,
        dosage: dosage,
        schedules: _cleanSchedules(schedules),
        urlPhoto: urlPhoto ?? current.urlPhoto,
        aineId: aineId ?? current.aineId,
        isActive: isActive ?? current.isActive,
      );

      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteMedication(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));

      final initialLength = _medications.length;
      _medications.removeWhere((m) => m.id == id);

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
}
