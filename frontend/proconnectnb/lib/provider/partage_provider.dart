import 'package:flutter/material.dart';
import '../../models/partage_suivi.dart';
import 'auth_provider.dart';

class PartageProvider extends ChangeNotifier {
  bool _isLoading = false;
  String _error = '';
  final List<PartageSuivi> _partages = [];

  bool get isLoading => _isLoading;
  String get error => _error;
  List<PartageSuivi> get partages => List.unmodifiable(_partages);

  Future<bool> aineAjouteProche({
    required int aineId,
    required int procheId,
    required String relation,
    required AuthProvider auth,
    String? procheEmail,
  }) async {
    _setLoading(true);
    _error = '';

    try {
      final normalizedEmail = procheEmail?.toLowerCase().trim();

      final existeDeja = _partages.any((p) {
        final sameAine = p.aineId == aineId;

        final sameProcheId = procheId != 0 && p.procheAidantId == procheId;

        final sameEmail =
            normalizedEmail != null &&
            normalizedEmail.isNotEmpty &&
            p.procheEmail?.toLowerCase().trim() == normalizedEmail;

        return sameAine && (sameProcheId || sameEmail);
      });

      if (existeDeja) {
        _error = 'Ce proche a déjà une invitation ou un lien avec cet aîné';
        return false;
      }

      final partage = PartageSuivi(
        id: DateTime.now().millisecondsSinceEpoch,
        autorisation: Autorisation.complete,
        relation: relation,
        aineId: aineId,
        procheAidantId: procheId,
        procheEmail: normalizedEmail,
        statut: StatutPartage.enAttente,
      );

      await Future.delayed(const Duration(milliseconds: 300));

      _partages.add(partage);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors du partage : $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchPartages(AuthProvider auth) async {
    _setLoading(true);
    _error = '';

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      notifyListeners();
    } catch (e) {
      _error = 'Impossible de charger les partages : $e';
    } finally {
      _setLoading(false);
    }
  }

  List<PartageSuivi> getPartagesParAine(int aineId) {
    return _partages
        .where((p) => p.aineId == aineId && p.statut == StatutPartage.actif)
        .toList();
  }

  List<PartageSuivi> getPartagesParProche(int procheId) {
    return _partages
        .where(
          (p) =>
              p.procheAidantId == procheId && p.statut == StatutPartage.actif,
        )
        .toList();
  }

  List<PartageSuivi> getTousPartagesParAine(int aineId) {
    return _partages.where((p) => p.aineId == aineId).toList();
  }

  List<PartageSuivi> getTousPartagesParProche(int procheId) {
    return _partages.where((p) => p.procheAidantId == procheId).toList();
  }

  List<PartageSuivi> getDemandesParEmail(String email) {
    final normalizedEmail = email.toLowerCase().trim();

    return _partages
        .where(
          (p) =>
              p.procheEmail?.toLowerCase().trim() == normalizedEmail &&
              p.statut == StatutPartage.enAttente,
        )
        .toList();
  }

  List<PartageSuivi> getDemandesPourProche(AuthProvider auth) {
    final procheId = auth.currentUserLocalId ?? 0;
    final email = auth.email?.toLowerCase().trim();

    return _partages.where((p) {
      final idMatch = procheId != 0 && p.procheAidantId == procheId;

      final emailMatch =
          email != null &&
          email.isNotEmpty &&
          p.procheEmail?.toLowerCase().trim() == email;

      return (idMatch || emailMatch) && p.statut == StatutPartage.enAttente;
    }).toList();
  }

  int countDemandesPourProche(AuthProvider auth) {
    if (auth.isAine) return 0;
    return getDemandesPourProche(auth).length;
  }

  PartageSuivi? getById(int id) {
    try {
      return _partages.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<bool> accepterDemande(int partageId, AuthProvider auth) async {
    _setLoading(true);
    _error = '';

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final index = _partages.indexWhere((p) => p.id == partageId);

      if (index == -1) {
        _error = 'Demande introuvable';
        return false;
      }

      final partage = _partages[index];

      final currentUserId = auth.currentUserLocalId ?? 0;
      final currentEmail = auth.email?.toLowerCase().trim();

      final emailMatch =
          currentEmail != null &&
          partage.procheEmail?.toLowerCase().trim() == currentEmail;

      _partages[index] = partage.copyWith(
        statut: StatutPartage.actif,
        procheAidantId: emailMatch ? currentUserId : partage.procheAidantId,
      );

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de l’acceptation : $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> refuserDemande(int partageId) async {
    _setLoading(true);
    _error = '';

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final index = _partages.indexWhere((p) => p.id == partageId);

      if (index == -1) {
        _error = 'Demande introuvable';
        return false;
      }

      _partages[index] = _partages[index].copyWith(
        statut: StatutPartage.refuse,
      );

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors du refus : $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> supprimerPartage(int partageId) async {
    _setLoading(true);
    _error = '';

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      _partages.removeWhere((p) => p.id == partageId);

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la suppression : $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  String getStatutLabel(StatutPartage statut) {
    switch (statut) {
      case StatutPartage.actif:
        return 'Lien établi';
      case StatutPartage.enAttente:
        return 'En attente';
      case StatutPartage.refuse:
        return 'Refusé';
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  void clearPartages() {
    _partages.clear();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
