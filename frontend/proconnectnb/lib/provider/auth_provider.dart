import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _currentUserEmail;

  bool get isAuthenticated => _isAuthenticated;
  String? get currentUserEmail => _currentUserEmail;

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    if (email == 'test@test.com' && password == '1234') {
      _isAuthenticated = true;
      _currentUserEmail = email;
      notifyListeners();
      return true;
    }

    _isAuthenticated = false;
    _currentUserEmail = null;
    notifyListeners();
    return false;
  }

  void logout() {
    _isAuthenticated = false;
    _currentUserEmail = null;
    notifyListeners();
  }
}
