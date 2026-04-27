import 'package:flutter/material.dart';

class Medication {
  final String id;
  final String name;
  final String dosage;
  final String time;
  bool isTaken;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.time,
    this.isTaken = false,
  });
}

class MedicationProvider with ChangeNotifier {
  final List<Medication> _medications = [
    Medication(
      id: '1',
      name: 'Amoxicilline',
      dosage: '500mg',
      time: '08:00',
      isTaken: true,
    ),
    Medication(
      id: '2',
      name: 'Lisinopril',
      dosage: '10mg',
      time: '20:00',
      isTaken: false,
    ),
  ];

  List<Medication> get medications => List.unmodifiable(_medications);

  double get adherenceRate {
    if (_medications.isEmpty) return 0.0;
    int takenCount = _medications.where((m) => m.isTaken).length;
    return takenCount / _medications.length;
  }

  void toggleStatus(String id) {
    final int index = _medications.indexWhere((m) => m.id == id);
    if (index != -1) {
      _medications[index].isTaken = !_medications[index].isTaken;
      notifyListeners();
    }
  }

  void renewMedication(String id) {
    final int index = _medications.indexWhere((m) => m.id == id);
    if (index != -1) {
      _medications[index].isTaken = false;
      notifyListeners();
    }
  }

  Future<bool> addMedication(String name, String dosage, String time) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final Medication newMed = Medication(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        dosage: dosage,
        time: time,
      );

      _medications.add(newMed);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateMedication(
    String id,
    String name,
    String dosage,
    String time,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final int index = _medications.indexWhere((m) => m.id == id);
      if (index != -1) {
        final bool currentTakenStatus = _medications[index].isTaken;

        _medications[index] = Medication(
          id: id,
          name: name,
          dosage: dosage,
          time: time,
          isTaken: currentTakenStatus,
        );

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteMedication(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final int initialLength = _medications.length;
      _medications.removeWhere((m) => m.id == id);

      if (_medications.length < initialLength) {
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
