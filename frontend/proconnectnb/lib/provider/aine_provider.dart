import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/aine.dart';
import '../models/adresse.dart';
import '../services/aine_service.dart';
import 'auth_provider.dart';

class AineProvider with ChangeNotifier {
  final AineService _service = AineService();

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

  Future<void> fetchAines(AuthProvider auth) async {
    _setLoading(true);

    try {
      /*
      if (auth.token == null) return;
      _aines = await _service.getAines(auth.token!);
      */

      await Future.delayed(const Duration(seconds: 1));

      if (_aines.isEmpty) {
        _aines = [
          Aine(
            id: 1,
            nom: "Aubie",
            prenom: "Jean-Guy",
            telephone: "506-546-0000",
            email: "jean.guy@nb.ca",
            dateNaissance: DateTime(1948, 10, 15),
            adresse: Adresse(
              rue: "789 Avenue des Pionniers",
              ville: "Bathurst",
              codePostal: "E2A 1V8",
            ),
            docteur: "Dr. Richard",
            numeroDocteur: "506-548-1234",
          ),
        ];
      }

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
      /*
      if (auth.token == null) return false;
      final success = await _service.createAine(data, auth.token!);
      if (success) {
        await fetchAines(auth);
        return true;
      }
      */

      await Future.delayed(const Duration(milliseconds: 800));

      final nouvelAine = Aine(
        id: DateTime.now().millisecondsSinceEpoch,
        nom: data['nom'] ?? '',
        prenom: data['prenom'] ?? '',
        telephone: data['telephone'] ?? '',
        email: data['email'] ?? '',
        dateNaissance: data['dateNaissance'] != null
            ? DateTime.parse(data['dateNaissance'])
            : DateTime.now(),
        adresse: data['adresse'] != null
            ? Adresse.fromJson(data['adresse'])
            : null,
        docteur: data['docteur'] ?? '',
        numeroDocteur: data['numeroTelephoneDocteur'] ?? '',
      );

      _aines.insert(0, nouvelAine);
      _error = '';
      notifyListeners();

      return true;
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
      /*
      if (auth.token == null) return false;
      final success = await _api.delete("/api/Aine/$id", auth.token!);
      */

      await Future.delayed(const Duration(milliseconds: 500));

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
      /*
      if (auth.token == null) return false;
      final success = await _service.updateAine(id, data, auth.token!);
      */

      await Future.delayed(const Duration(milliseconds: 500));

      final index = _aines.indexWhere((a) => a.id == id);

      if (index != -1) {
        final updatedAine = Aine.fromJson({...data, 'id': id});

        _aines[index] = updatedAine;

        if (_selectedAine?.id == id) {
          _selectedAine = updatedAine;
        }

        _error = '';
        notifyListeners();
      }

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
