import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';
import 'auth_provider.dart';

class AppointmentProvider with ChangeNotifier {
  final AppointmentService _service = AppointmentService();

  List<RendezVousMedical> _appointments = [];
  bool _isLoading = false;
  String _error = '';

  List<RendezVousMedical> get appointments => List.unmodifiable(_appointments);
  bool get isLoading => _isLoading;
  String get error => _error;

  List<RendezVousMedical> get appointmentsDuJour {
    final today = DateTime.now();

    return _appointments.where((a) {
      return a.dateHeure.year == today.year &&
          a.dateHeure.month == today.month &&
          a.dateHeure.day == today.day;
    }).toList()..sort((a, b) => a.dateHeure.compareTo(b.dateHeure));
  }

  Future<void> fetchAppointments(AuthProvider auth) async {
    if (auth.token == null) return;

    _setLoading(true);

    try {
      final result = await _service.getAppointments(auth.token!);
      _appointments = result.whereType<RendezVousMedical>().toList();
      _error = '';
    } catch (_) {
      _error = "Erreur lors du chargement des rendez-vous";
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addAppointment(
    Map<String, dynamic> data,
    AuthProvider auth,
  ) async {
    if (auth.token == null) return false;

    _setLoading(true);

    try {
      final success = await _service.createAppointment(data, auth.token!);

      if (success) {
        await fetchAppointments(auth);
        return true;
      }

      _error = "Échec de création";
      return false;
    } catch (_) {
      _error = "Erreur lors de la création";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addLocalAppointment(RendezVousMedical rdv) async {
    _appointments.add(rdv);
    _appointments.sort((a, b) => a.dateHeure.compareTo(b.dateHeure));
    notifyListeners();
    return true;
  }

  Future<bool> deleteAppointment(int id, AuthProvider auth) async {
    if (auth.token == null) return false;

    try {
      final success = await _service.deleteAppointment(id, auth.token!);

      if (success) {
        _appointments.removeWhere((a) => a.id == id);
        notifyListeners();
      }

      return success;
    } catch (_) {
      _error = "Erreur lors de la suppression";
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAppointment(
    int id,
    Map<String, dynamic> data,
    AuthProvider auth,
  ) async {
    if (auth.token == null) return false;

    try {
      final success = await _service.updateAppointment(id, data, auth.token!);

      if (success) {
        await fetchAppointments(auth);
      }

      return success;
    } catch (_) {
      _error = "Erreur lors de la mise à jour";
      notifyListeners();
      return false;
    }
  }

  List<RendezVousMedical> get upcomingAppointments {
    final now = DateTime.now();

    final list = _appointments.where((a) => a.dateHeure.isAfter(now)).toList();

    list.sort((a, b) => a.dateHeure.compareTo(b.dateHeure));
    return list;
  }

  List<RendezVousMedical> get pastAppointments {
    final now = DateTime.now();

    final list = _appointments.where((a) => a.dateHeure.isBefore(now)).toList();

    list.sort((a, b) => b.dateHeure.compareTo(a.dateHeure));
    return list;
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
