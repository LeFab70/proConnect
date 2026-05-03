import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api.dart';

class AuthProvider with ChangeNotifier {
  final Api _api = Api();

  bool _isAuthenticated = false;
  bool _isLoading = false;

  String? _token;
  String? _email;
  String? _firstName;
  String? _role;
  int? _userId;
  String? _errorMessage;
  String? _profilePicture;

  int _nbDemandes = 0;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  String? get token => _token;
  String? get email => _email;
  String? get firstName => _firstName;
  String? get role => _role;
  int? get currentUserLocalId => _userId;
  String? get errorMessage => _errorMessage;
  String? get profilePicture => _profilePicture;

  int get nbDemandes => _nbDemandes;

  bool get isAine => _role == "AINE";
  bool get isAidant => _role == "AIDANT";

  void setNbDemandes(int count) {
    _nbDemandes = count;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    if (_isLoading) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _api.login(email, password);

      if (result == null || result["success"] == false) {
        _errorMessage = result["message"] ?? "Email ou mot de passe incorrect";
        _isAuthenticated = false;
        return false;
      }

      _token = result["token"];
      _email = email.trim().toLowerCase();
      _firstName = result["firstName"] ?? email.split('@')[0];
      _role = result["role"];
      _userId = result["userId"];
      _profilePicture = result["profilePicture"];

      if (result["nbDemandes"] != null) {
        _nbDemandes = result["nbDemandes"];
      }

      if (_token == null || _role == null) {
        _errorMessage = "Réponse serveur invalide";
        _isAuthenticated = false;
        return false;
      }

      _isAuthenticated = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", _token!);
      await prefs.setString("email", _email!);
      await prefs.setString("firstName", _firstName ?? "");
      await prefs.setString("role", _role!);
      if (_userId != null) await prefs.setInt("userId", _userId!);
      await prefs.setString("profilePicture", _profilePicture ?? "");
      await prefs.setBool("isAuth", true);

      return true;
    } catch (e) {
      _errorMessage = "Erreur de connexion";
      _isAuthenticated = false;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /*
  REGISTER FINAL AVEC APPEL api.register(...)
  Future<bool> register({
  required String firstName,
  required String lastName,
  required String email,
  required String password,
  required String phone,
  required String role,
}) async {
  if (_isLoading) return false;

  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    final result = await _api.register(
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: email.trim().toLowerCase(),
      password: password.trim(),
      phone: phone.trim(),
      role: role,
    );

    if (result == null || result["success"] == false) {
      _errorMessage = result?["message"] ?? "Erreur création compte";
      _isAuthenticated = false;
      return false;
    }

    _token = result["token"];
    _email = email.trim().toLowerCase();
    _firstName = result["firstName"] ?? firstName.trim();
    _role = result["role"] ?? role;
    _userId = result["userId"];
    _profilePicture = result["profilePicture"];
    _nbDemandes = result["nbDemandes"] ?? 0;

    if (_token == null || _role == null || _userId == null) {
      return await login(email.trim().toLowerCase(), password.trim());
    }

    _isAuthenticated = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", _token!);
    await prefs.setString("email", _email!);
    await prefs.setString("firstName", _firstName ?? "");
    await prefs.setString("role", _role!);
    await prefs.setInt("userId", _userId!);
    await prefs.setString("profilePicture", _profilePicture ?? "");
    await prefs.setBool("isAuth", true);

    return true;
  } catch (e) {
    _errorMessage = "Erreur serveur lors de l'inscription";
    _isAuthenticated = false;
    return false;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
*/
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) async {
    if (_isLoading) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));

      /// 🔥 SIMULATION UTILISATEUR LOCAL
      _token = "LOCAL_TOKEN";
      _email = email.trim().toLowerCase();
      _firstName = firstName.trim();
      _role = role;
      _userId = DateTime.now().millisecondsSinceEpoch;
      _profilePicture = null;
      _nbDemandes = 0;

      _isAuthenticated = true;

      /// 💾 SAUVEGARDE LOCALE
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", _token!);
      await prefs.setString("email", _email!);
      await prefs.setString("firstName", _firstName ?? "");
      await prefs.setString("role", _role!);
      await prefs.setInt("userId", _userId!);
      await prefs.setString("profilePicture", "");
      await prefs.setBool("isAuth", true);

      return true;
    } catch (e) {
      _errorMessage = "Erreur lors de l'inscription";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString("token");
    final email = prefs.getString("email");
    final role = prefs.getString("role");
    final firstName = prefs.getString("firstName");
    final profilePicture = prefs.getString("profilePicture");
    final isAuth = prefs.getBool("isAuth") ?? false;
    final userId = prefs.getInt("userId");

    if (!isAuth ||
        token == null ||
        token.isEmpty ||
        role == null ||
        role.isEmpty) {
      return false;
    }

    _token = token;
    _email = email;
    _role = role;
    _userId = userId;
    _firstName = firstName;
    _profilePicture = (profilePicture == null || profilePicture.isEmpty)
        ? null
        : profilePicture;
    _isAuthenticated = true;

    notifyListeners();
    return true;
  }

  Future<void> updateProfilePicture(String newUrl) async {
  _profilePicture = newUrl.trim().isEmpty ? null : newUrl;

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString("profilePicture", _profilePicture ?? "");

  notifyListeners();
}

  Future<void> updateUserInfo({String? newName, String? newEmail}) async {
    final prefs = await SharedPreferences.getInstance();

    if (newName != null && newName.trim().isNotEmpty) {
      _firstName = newName.trim();
      await prefs.setString("firstName", _firstName!);
    }

    if (newEmail != null && newEmail.trim().isNotEmpty) {
      _email = newEmail.trim().toLowerCase();
      await prefs.setString("email", _email!);
    }

    notifyListeners();
  }

  //METHODE POUR MODIFIER LE MOT DE PASSE
  Future<bool> updatePassword(String newPassword) async {
    try {
      //final result = await _api.changePassword(_token, newPassword);

      // Simulation d'une réussite pour le moment
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> clearProfilePicture() async {
    _profilePicture = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("profilePicture");

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _isAuthenticated = false;
    _isLoading = false;
    _token = null;
    _email = null;
    _role = null;
    _userId = null;
    _firstName = null;
    _errorMessage = null;
    _profilePicture = null;
    _nbDemandes = 0;

    notifyListeners();
  }

  void reset() {
    _isAuthenticated = false;
    _isLoading = false;
    _token = null;
    _email = null;
    _role = null;
    _firstName = null;
    _userId = null;
    _errorMessage = null;
    _profilePicture = null;
    _nbDemandes = 0;

    notifyListeners();
  }
}
