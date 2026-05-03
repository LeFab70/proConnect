import 'package:flutter/material.dart';

import '../models/caregiver.dart';
import '../models/adresse.dart';
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

  Future<void> fetchCaregivers(AuthProvider auth) async {
    _setLoading(true);
    _error = '';

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      if (_caregivers.isEmpty) {
        _caregivers = [
          Caregiver(
            id: 1,
            nom: "Aubie",
            prenom: "Kayleb",
            telephone: "506-123-4567",
            email: "kayleb@test.com",
            adresse: Adresse(
              rue: "123 Rue Main",
              ville: "Bathurst",
              codePostal: "E2A 1A1",
            ),
          ),
        ];
      }
    } catch (e) {
      _error = "Erreur lors du chargement des proches";
    } finally {
      _setLoading(false);
    }
  }

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
      await Future.delayed(const Duration(milliseconds: 500));

      final nouveauCaregiver = Caregiver(
        id: DateTime.now().millisecondsSinceEpoch,
        nom: nom,
        prenom: prenom,
        telephone: telephone,
        email: email,
        adresse: adresse,
      );

      _caregivers.insert(0, nouveauCaregiver);
      notifyListeners();
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
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _caregivers.indexWhere((c) => c.id == id);

      if (index == -1) {
        _error = "Proche introuvable";
        return false;
      }

      _caregivers[index] = Caregiver.fromJson({...data, 'id': id});

      notifyListeners();
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
      await Future.delayed(const Duration(milliseconds: 500));

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
