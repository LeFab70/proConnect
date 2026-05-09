import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/aine.dart';
import '../services/aine_service.dart';
import '../services/api.dart';
import 'auth_provider.dart';

class AineProvider with ChangeNotifier {
  final AineService _service = AineService();
  final Api _api = Api();

  static const String _selectedAineKey = "selectedAineId";

  List<Aine> _aines = [];
  Aine? _selectedAine;

  bool _isLoading = false;
  String _error = '';

  List<Aine> get aines => List.unmodifiable(_aines);
  Aine? get selectedAine => _selectedAine;

  bool get isLoading => _isLoading;
  String get error => _error;
  bool get hasSelectedAine => _selectedAine != null;

  Future<void> selectAine(Aine aine) async {
    _selectedAine = aine;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_selectedAineKey, aine.id);

    notifyListeners();
  }

  Future<void> setSelectedAine(Aine aine) async {
    await selectAine(aine);
  }

  Future<void> clearSelectedAine() async {
    _selectedAine = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_selectedAineKey);

    notifyListeners();
  }

  Future<void> restoreSelectedAine() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedId = prefs.getInt(_selectedAineKey);

    if (selectedId == null) return;

    try {
      _selectedAine = _aines.firstWhere((a) => a.id == selectedId);
    } catch (_) {
      _selectedAine = null;
      await prefs.remove(_selectedAineKey);
    }

    notifyListeners();
  }

  // Fabrice | 2026-05-05T04:47:29Z | Charge les aînés depuis /api/aines avec le JWT courant.
  Future<void> fetchAines(AuthProvider auth) async {
    _setLoading(true);

    try {
      if (auth.token == null) return;

      // Fabrice | 2026-05-05T06:00:00Z | Côté backend : /api/aines/mine renvoie les aînés liés au proche aidant connecté.
      _aines = auth.isAidant
          ? await _service.getAinesMine(auth.token!)
          : await _service.getAines(auth.token!);

      await restoreSelectedAine();
      _error = '';
    } catch (e) {
      _error = "Erreur lors du chargement des aînés";
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addAine(Map<String, dynamic> data, AuthProvider auth) async {
    _setLoading(true);

    try {
      if (auth.token == null) return false;
      final success = await _service.createAine(data, auth.token!);
      if (success) {
        await fetchAines(auth);
        return true;
      }
      _error = "Création refusée (droits admin requis côté API)";
      return false;
    } catch (e) {
      _error = "Erreur lors de la création";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAine(int id, AuthProvider auth) async {
    _setLoading(true);

    try {
      if (auth.token == null) return false;
      // Fabrice | 2026-05-05T04:47:29Z | DELETE /api/aines/{id} (policy AdminOnly sur l’API).
      final success = await _api.delete("/api/aines/$id", auth.token!);
      if (!success) {
        _error = "Suppression refusée (droits admin requis côté API)";
        return false;
      }

      _aines.removeWhere((a) => a.id == id);

      if (_selectedAine?.id == id) {
        await clearSelectedAine();
      }

      _error = '';
      notifyListeners();

      return true;
    } catch (e) {
      _error = "Erreur lors de la suppression";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateAine(
    int id,
    Map<String, dynamic> data,
    AuthProvider auth,
  ) async {
    _setLoading(true);

    try {
      if (auth.token == null) return false;
      final success = await _service.updateAine(id, data, auth.token!);
      if (!success) {
        _error = "Mise à jour refusée (droits admin requis côté API)";
        return false;
      }

      await fetchAines(auth);

      final index = _aines.indexWhere((a) => a.id == id);
      if (index != -1 && _selectedAine?.id == id) {
        _selectedAine = _aines[index];
        notifyListeners();
      }

      _error = '';
      return true;
    } catch (e) {
      _error = "Erreur lors de la mise à jour";
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> reset() async {
    _aines = [];
    _selectedAine = null;
    _isLoading = false;
    _error = '';

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_selectedAineKey);

    notifyListeners();
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
