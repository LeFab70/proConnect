import 'package:flutter/material.dart';

import '../models/partage_suivi.dart';
import '../services/api.dart';
import 'auth_provider.dart';

class PartageProvider extends ChangeNotifier {
  final Api _api = Api();

  bool _isLoading = false;
  String _error = '';

  final List<PartageSuivi> _partages = [];
  final Set<int> _notificationsMasquees = {};

  bool get isLoading => _isLoading;
  String get error => _error;
  List<PartageSuivi> get partages => List.unmodifiable(_partages);

  PartageSuivi _partageFromApi(Map<String, dynamic> m) {
    return PartageSuivi.fromJson(m);
  }

  Future<bool> aineAjouteProche({
    required int aineId,
    required int procheId,
    required String relation,
    required AuthProvider auth,
    String? procheEmail,
    String? procheNom,
    String? prochePrenom,
    String? procheTelephone,
    String? aineNom,
    String? ainePrenom,
    String? aineEmail,
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

        return sameAine &&
            (sameProcheId || sameEmail) &&
            p.statut != StatutPartage.refuse;
      });

      if (existeDeja) {
        _error = 'Ce proche a déjà une invitation ou un lien avec cet aîné';
        notifyListeners();
        return false;
      }

      if (auth.token == null) {
        _error = 'Session invalide';
        notifyListeners();
        return false;
      }

      final partage = PartageSuivi(
        id: DateTime.now().millisecondsSinceEpoch,
        autorisation: Autorisation.complete,
        relation: relation.trim().isNotEmpty
            ? relation.trim()
            : 'Proche aidant',
        aineId: aineId,
        procheAidantId: procheId,
        procheEmail: normalizedEmail,
        procheNom: procheNom,
        prochePrenom: prochePrenom,
        procheTelephone: procheTelephone,
        aineNom: aineNom,
        ainePrenom: ainePrenom,
        aineEmail: aineEmail,
        statut: StatutPartage.enAttente,
      );

      final ok = await _api.upsertPartage(partage, auth.token!);

      if (!ok) {
        _error = 'Création du partage refusée';
        notifyListeners();
        return false;
      }

      await fetchPartages(auth);
      return true;
    } catch (e) {
      _error = 'Erreur lors du partage : $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchPartages(AuthProvider auth) async {
    _setLoading(true);
    _error = '';

    try {
      if (auth.token == null) {
        _error = 'Session invalide';
        return;
      }

      final raw = await _api.getPartagesSuivi(auth.token!);

      _partages
        ..clear()
        ..addAll(raw.map((e) => _partageFromApi(e as Map<String, dynamic>)));

      notifyListeners();
    } catch (e) {
      _error = 'Impossible de charger les partages : $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  List<PartageSuivi> getDemandesPourProche(AuthProvider auth) {
    if (auth.isAine) return [];

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
    return getDemandesPourProche(auth).length;
  }

  Future<bool> accepterDemande(int partageId, AuthProvider auth) async {
    _setLoading(true);
    _error = '';

    try {
      if (auth.token == null) {
        _error = 'Session invalide';
        notifyListeners();
        return false;
      }

      final index = _partages.indexWhere((p) => p.id == partageId);

      if (index == -1) {
        _error = 'Demande introuvable';
        notifyListeners();
        return false;
      }

      final ancienPartage = _partages[index];

      print("ACCEPTATION DEMANDE ID = $partageId");

      final ok = await _api.acceptPartage(partageId, auth.token!);

      print("RESULT ACCEPT = $ok");

      if (!ok) {
        _error = 'Le serveur a refusé la demande';
        notifyListeners();
        return false;
      }

      _partages[index] = ancienPartage.copyWith(
        statut: StatutPartage.actif,
        procheAidantId: auth.currentUserLocalId ?? ancienPartage.procheAidantId,
        procheEmail: auth.email ?? ancienPartage.procheEmail,
        procheNom: auth.nom ?? ancienPartage.procheNom,
        prochePrenom: auth.prenom ?? ancienPartage.prochePrenom,
      );

      notifyListeners();

      await fetchPartages(auth);

      return true;
    } catch (e) {
      print("ERREUR ACCEPT = $e");

      _error = 'Erreur lors de l’acceptation : $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> refuserDemande(int partageId, AuthProvider auth) async {
    _setLoading(true);
    _error = '';

    try {
      if (auth.token == null) {
        _error = 'Session invalide';
        notifyListeners();
        return false;
      }

      final index = _partages.indexWhere((p) => p.id == partageId);

      if (index == -1) {
        _error = 'Demande introuvable';
        notifyListeners();
        return false;
      }

      final ancienPartage = _partages[index];

      final ok = await _api.rejectPartage(partageId, auth.token!);

      if (!ok) {
        _error = 'Impossible de refuser la demande';
        notifyListeners();
        return false;
      }

      _partages[index] = ancienPartage.copyWith(
        statut: StatutPartage.refuse,
        procheNom: auth.nom ?? ancienPartage.procheNom,
        prochePrenom: auth.prenom ?? ancienPartage.prochePrenom,
      );

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors du refus : $e';
      notifyListeners();
      return false;
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

  List<PartageSuivi> getReponsesPourAine(AuthProvider auth) {
    final aineId = auth.currentUserLocalId ?? 0;

    if (!auth.isAine || aineId == 0) return [];

    return _partages.where((p) {
      return p.aineId == aineId &&
          !_notificationsMasquees.contains(p.id) &&
          (p.statut == StatutPartage.actif || p.statut == StatutPartage.refuse);
    }).toList();
  }

  int countReponsesPourAine(AuthProvider auth) {
    return getReponsesPourAine(auth).length;
  }

  void masquerNotification(int partageId) {
    _notificationsMasquees.add(partageId);
    notifyListeners();
  }

  PartageSuivi? getById(int id) {
    try {
      return _partages.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<bool> supprimerPartage(int partageId, AuthProvider auth) async {
    _setLoading(true);
    _error = '';

    try {
      if (auth.token != null) {
        await _api.delete('/api/partages-suivi/$partageId', auth.token!);
      }

      _partages.removeWhere((p) => p.id == partageId);
      _notificationsMasquees.remove(partageId);

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la suppression : $e';
      notifyListeners();
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
    _notificationsMasquees.clear();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
