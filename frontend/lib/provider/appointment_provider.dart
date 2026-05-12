import 'package:flutter/material.dart';

import '../models/appointment.dart';
import '../services/appointment_service.dart';
import 'auth_provider.dart';

class AppointmentProvider with ChangeNotifier {
  final AppointmentService _service = AppointmentService();

  final List<RendezVousMedical> _appointments = [];

  bool _isLoading = false;
  String _error = '';

  List<RendezVousMedical> get appointments {
    final list = [..._appointments];
    list.sort((a, b) => a.dateHeure.compareTo(b.dateHeure));
    return List.unmodifiable(list);
  }

  bool get isLoading => _isLoading;
  String get error => _error;

  List<RendezVousMedical> get appointmentsDuJour {
    final today = DateTime.now();

    final list = _appointments.where((a) {
      return a.dateHeure.year == today.year &&
          a.dateHeure.month == today.month &&
          a.dateHeure.day == today.day;
    }).toList();

    list.sort((a, b) => a.dateHeure.compareTo(b.dateHeure));
    return list;
  }

  List<RendezVousMedical> get upcomingAppointments {
    final now = DateTime.now();

    final list = _appointments.where((a) {
      return a.dateHeure.isAfter(now);
    }).toList();

    list.sort((a, b) => a.dateHeure.compareTo(b.dateHeure));
    return list;
  }

  List<RendezVousMedical> get pastAppointments {
    final now = DateTime.now();

    final list = _appointments.where((a) {
      return !a.dateHeure.isAfter(now);
    }).toList();

    list.sort((a, b) => b.dateHeure.compareTo(a.dateHeure));
    return list;
  }

  Future<void> fetchAppointments(AuthProvider auth) async {
    if (auth.token == null || auth.token!.isEmpty) {
      return;
    }

    _setLoading(true);

    try {
      final result = await _service.getAppointments(auth.token!);

      _appointments
        ..clear()
        ..addAll(result.whereType<RendezVousMedical>());

      _appointments.sort((a, b) => a.dateHeure.compareTo(b.dateHeure));
      _error = '';
    } catch (_) {
      _error = "Erreur lors du chargement des rendez-vous";
    } finally {
      _setLoading(false);
    }
  }

  Future<RendezVousMedical?> addAppointment(
    Map<String, dynamic> data,
    AuthProvider auth,
  ) async {
    if (auth.token == null || auth.token!.isEmpty) {
      _error = "Session invalide";
      return null;
    }

    _setLoading(true);

    try {
      final result = await _service.createAppointment(data, auth.token!);
      final ok = result["success"] == true;

      if (ok) {
        final created = result["appointment"] as RendezVousMedical?;
        if (created == null) {
          _error = "Réponse serveur invalide";
          return null;
        }
        // Keep local list aligned with server IDs immediately
        final index = _appointments.indexWhere((a) => a.id == created.id);
        if (index == -1) {
          _appointments.add(created);
        } else {
          _appointments[index] = created;
        }
        _appointments.sort((a, b) => a.dateHeure.compareTo(b.dateHeure));
        _error = '';
        notifyListeners();
        return created;
      }

      _error = result["message"]?.toString() ?? "Échec de création";
      notifyListeners();
      return null;
    } catch (_) {
      _error = "Erreur lors de la création";
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addLocalAppointment(RendezVousMedical rdv) async {
    final index = _appointments.indexWhere((a) => a.id == rdv.id);

    if (index == -1) {
      _appointments.add(rdv);
    } else {
      _appointments[index] = rdv;
    }

    _appointments.sort((a, b) => a.dateHeure.compareTo(b.dateHeure));
    _error = '';
    notifyListeners();

    return true;
  }

  Future<bool> updateLocalAppointment(RendezVousMedical rdv) async {
    final index = _appointments.indexWhere((a) => a.id == rdv.id);

    if (index == -1) {
      _error = "Rendez-vous introuvable";
      notifyListeners();
      return false;
    }

    _appointments[index] = rdv;
    _appointments.sort((a, b) => a.dateHeure.compareTo(b.dateHeure));

    _error = '';
    notifyListeners();

    return true;
  }

  Future<bool> deleteAppointment(int id, AuthProvider auth) async {
    if (auth.token == null || auth.token!.isEmpty) {
      return deleteLocalAppointment(id);
    }

    try {
      final success = await _service.deleteAppointment(id, auth.token!);

      if (success) {
        _appointments.removeWhere((a) => a.id == id);
        _error = '';
        notifyListeners();
      }

      return success;
    } catch (_) {
      _error = "Erreur lors de la suppression";
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteLocalAppointment(int id) async {
    _appointments.removeWhere((a) => a.id == id);
    _error = '';
    notifyListeners();
    return true;
  }

  Future<bool> updateAppointment(
    int id,
    Map<String, dynamic> data,
    AuthProvider auth,
  ) async {
    if (auth.token == null || auth.token!.isEmpty) {
      return false;
    }

    try {
      final success = await _service.updateAppointment(id, data, auth.token!);

      if (success) {
        await fetchAppointments(auth);
        _error = '';
      }

      return success;
    } catch (_) {
      _error = "Erreur lors de la mise à jour";
      notifyListeners();
      return false;
    }
  }

  RendezVousMedical? getAppointmentById(int id) {
    try {
      return _appointments.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  void clearAppointments() {
    _appointments.clear();
    _error = '';
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
