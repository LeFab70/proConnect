import 'package:flutter/material.dart';

import '../models/rappel.dart';
import '../services/rappel_service.dart';
import '../services/notification_service.dart';
import 'auth_provider.dart';

class RappelProvider with ChangeNotifier {
  final RappelService _service = RappelService();

  final List<Rappel> _rappels = [];
  final Map<int, DateTime> _scheduledAt = {};

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
      await _syncNotifications();
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur fetchRappels: $e');
    }
  }

  Future<void> _syncNotifications() async {
    int notifIdFor(Rappel r) {
      // Android notification ids are effectively 32-bit; keep stable + positive.
      return (r.id.hashCode & 0x7fffffff);
    }

    final active = _rappels.where((r) => r.actif).toList();
    final desiredIds = active.map((r) => notifIdFor(r)).toSet();

    // Cancel notifications that are no longer active/present.
    final toCancel = _scheduledAt.keys
        .where((id) => !desiredIds.contains(id))
        .toList();
    for (final id in toCancel) {
      await NotificationService.cancelNotification(id);
      _scheduledAt.remove(id);
    }

    // Schedule / reschedule active notifications.
    for (final r in active) {
      final notifId = notifIdFor(r);
      final scheduledAt = _scheduledAt[notifId];

      // If time changed, cancel then reschedule.
      if (scheduledAt != null && scheduledAt != r.dateHeureNotification) {
        await NotificationService.cancelNotification(notifId);
        _scheduledAt.remove(notifId);
      }

      if (_scheduledAt.containsKey(notifId)) continue;

      String hhmm(DateTime d) =>
          '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
      final title = r.type.toLowerCase().contains('medicament')
          ? 'Rappel médicament'
          : 'Rappel rendez-vous';
      final body = r.type.toLowerCase().contains('medicament')
          ? 'Prise prévue à ${hhmm(r.dateHeurePrise)} — rappel à ${hhmm(r.dateHeureNotification)}'
          : 'Rappel à ${hhmm(r.dateHeureNotification)} (RDV ${hhmm(r.dateHeurePrise)})';

      await NotificationService.scheduleOneShotAt(
        id: notifId,
        title: title,
        body: body,
        dateTime: r.dateHeureNotification,
      );

      _scheduledAt[notifId] = r.dateHeureNotification;
    }
  }

  Future<bool> addRappel(Rappel rappel, AuthProvider auth) async {
    final existeDeja = _rappels.any((r) {
      if (rappel.rendezVousMedicalId != null) {
        // Un rappel différent (autre heure) pour le même RDV est autorisé.
        return r.rendezVousMedicalId == rappel.rendezVousMedicalId &&
            r.heureDebut == rappel.heureDebut;
      }

      if (rappel.medicamentId != null) {
        return r.medicamentId == rappel.medicamentId &&
            r.heureDebut == rappel.heureDebut &&
            r.dateHeurePrise == rappel.dateHeurePrise;
      }

      return r.type == rappel.type &&
          r.heureDebut == rappel.heureDebut &&
          r.dateHeurePrise == rappel.dateHeurePrise;
    });

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

        await _syncNotifications();

        return true;
      }

      // Connecté mais échec API : ne pas simuler un rappel local (id 0) — le lien serveur manquerait.
      return false;
    }

    _rappels.add(rappel);
    _sort();
    await _syncNotifications();
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
        await _syncNotifications();

        return true;
      }
    }

    final index = _rappels.indexWhere((r) => r.id == rappel.id);

    if (index == -1) return false;

    _rappels[index] = rappel;
    _sort();
    await _syncNotifications();
    notifyListeners();

    return true;
  }

  Future<bool> deleteRappel(int id, AuthProvider auth) async {
    await NotificationService.cancelNotification(id.hashCode & 0x7fffffff);
    _scheduledAt.remove(id.hashCode & 0x7fffffff);

    final token = auth.token;

    if (token != null && token.isNotEmpty && id > 0) {
      final ok = await _service.deleteRappel(id, token);

      if (ok) {
        _rappels.removeWhere((r) => r.id == id);
        await _syncNotifications();
        notifyListeners();
        return true;
      }
    }

    final initialLength = _rappels.length;

    _rappels.removeWhere((r) => r.id == id);

    if (_rappels.length < initialLength) {
      await _syncNotifications();
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

  Future<bool> addRappelLocalOnly(Rappel rappel) async {
    final existeDeja = _rappels.any((r) {
      if (rappel.rendezVousMedicalId != null) {
        return r.rendezVousMedicalId == rappel.rendezVousMedicalId &&
            r.heureDebut == rappel.heureDebut;
      }

      if (rappel.medicamentId != null) {
        return r.medicamentId == rappel.medicamentId &&
            r.heureDebut == rappel.heureDebut &&
            r.dateHeurePrise == rappel.dateHeurePrise;
      }

      return r.type == rappel.type &&
          r.heureDebut == rappel.heureDebut &&
          r.dateHeurePrise == rappel.dateHeurePrise;
    });

    if (existeDeja) return false;

    _rappels.add(rappel);
    _sort();
    await _syncNotifications();
    notifyListeners();

    return true;
  }
}
