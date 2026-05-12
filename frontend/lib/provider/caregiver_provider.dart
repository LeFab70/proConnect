import 'package:flutter/material.dart';

import '../models/adresse.dart';
import '../models/caregiver.dart';
import '../services/api.dart';
import 'auth_provider.dart';

class CaregiverProvider with ChangeNotifier {
  final Api _api = Api();

  List<Caregiver> _caregivers = [];
  bool _isLoading = false;
  String _error = '';

  List<Caregiver> get caregivers => List.unmodifiable(_caregivers);
  bool get isLoading => _isLoading;
  String get error => _error;

  // Fabrice | 2026-05-05T04:47:29Z | Charge les proches aidants depuis /api/proches-aidants.
  Future<void> fetchCaregivers(AuthProvider auth) async {
    _setLoading(true);
    _error = '';

    try {
      if (auth.token == null) return;

      final raw = await _api.getCaregivers(auth.token!);
      _caregivers = raw
          .map((e) => Caregiver.fromJson(e as Map<String, dynamic>))
          .toList();

      notifyListeners();
    } catch (e) {
      _error = "Erreur lors du chargement des proches";
    } finally {
      _setLoading(false);
    }
  }

  // Fabrice | 2026-05-05T04:56:37Z | POST /api/proches-aidants puis rafraîchissement liste (AdminOnly sur l’API).
  Future<bool> addCaregiver({
    required String nom,
    required String prenom,
    required String telephone,
    required String email,
    Adresse? adresse,
    required AuthProvider auth,
  }) async {
    _setLoading(true);
    _error = '';

    try {
      if (auth.token == null) return false;

      Map<String, dynamic>? addrBody;
      final rue = adresse?.rue?.trim() ?? '';
      final ville = adresse?.ville?.trim() ?? '';
      if (rue.isNotEmpty && ville.isNotEmpty) {
        final cp =
            (adresse?.codePostal ?? 'E1A1A1').replaceAll(RegExp(r'\s'), '');
        final numero = (adresse?.numero?.trim().isNotEmpty ?? false)
            ? adresse!.numero!.trim()
            : '1';
        final province =
            (adresse?.province?.trim().isNotEmpty ?? false)
                ? adresse!.province!.trim()
                : 'NB';
        // Fabrice | 2026-05-05T05:02:10Z | Corps conforme à AdresseDto (plus de numéro fictif systématique).
        addrBody = {
          'numero': numero,
          'rue': rue,
          'ville': ville,
          'codePostal': cp.length >= 3 ? cp : 'E1A1A1',
          'province': province,
        };
      }

      final ok = await _api.registerCaregiver(
        nom: nom,
        prenom: prenom,
        telephone: telephone,
        email: email,
        adresse: addrBody,
        token: auth.token!,
      );

      if (!ok) {
        _error =
            "Création refusée (droits admin requis côté API ou données invalides)";
        return false;
      }

      await fetchCaregivers(auth);
      return true;
    } catch (e) {
      _error = "Erreur lors de la création du proche";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateCaregiver(
    int id,
    Map<String, dynamic> data,
    AuthProvider auth,
  ) async {
    _setLoading(true);
    _error = '';

    try {
      if (auth.token == null) return false;

      final ok = await _api.put("/api/proches-aidants/$id", data, auth.token!);
      if (!ok) {
        _error = "Mise à jour refusée par le serveur";
        return false;
      }

      final index = _caregivers.indexWhere((c) => c.id == id);
      if (index != -1) {
        _caregivers[index] = Caregiver.fromJson({...data, 'id': id});
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = "Erreur lors de la modification du proche";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteCaregiver(int id, AuthProvider auth) async {
    _setLoading(true);
    _error = '';

    try {
      if (auth.token == null) return false;

      final ok = await _api.delete("/api/proches-aidants/$id", auth.token!);
      if (!ok) {
        _error = "Suppression refusée par le serveur";
        return false;
      }

      _caregivers.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = "Erreur lors de la suppression du proche";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Caregiver? getById(int id) {
    try {
      return _caregivers.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  void clearCaregivers() {
    _caregivers.clear();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
