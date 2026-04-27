import 'package:flutter/material.dart';
import '../models/aine.dart';
import '../services/aine_service.dart';
import 'auth_provider.dart';

class AineProvider with ChangeNotifier {
  final AineService _service = AineService();

  List<Aine> _aines = [];
  bool _isLoading = false;
  String _error = '';

  List<Aine> get aines => _aines;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchAines(AuthProvider auth) async {
    _isLoading = true;
    notifyListeners();

    try {
      _aines = await _service.getAines(auth.token!);
      _error = '';
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addAine(Map<String, dynamic> data, AuthProvider auth) async {
    try {
      bool success = await _service.createAine(data, auth.token!);

      if (success) {
        await fetchAines(auth); // refresh
      }

      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}