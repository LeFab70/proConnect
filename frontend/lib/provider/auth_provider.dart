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
  String? _lastName;
  String? _telephone;
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
  String? get lastName => _lastName;

  String? get prenom => _firstName;
  String? get nom => _lastName;
  String? get telephone => _telephone;

  String get fullName {
    final value = '${_firstName ?? ''} ${_lastName ?? ''}'.trim();
    return value.isNotEmpty ? value : (_email ?? '');
  }

  String? get role => _role;
  int? get currentUserLocalId => _userId;
  String? get errorMessage => _errorMessage;
  String? get profilePicture => _profilePicture;

  int get nbDemandes => _nbDemandes;

  bool get isAine {
    final r = (_role ?? '').trim().toUpperCase();
    return r == "AINE" || r == "AÎNÉ" || r == "AINEE";
  }

  bool get isAidant {
    final r = (_role ?? '').trim().toUpperCase();
    return r == "AIDANT" || r == "PROCHE" || r == "PROCHE_AIDANT";
  }

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

      if (result["success"] != true) {
        _errorMessage = result["message"] ?? "Email ou mot de passe incorrect";
        _isAuthenticated = false;
        return false;
      }

      _token = result["token"]?.toString();
      _email = email.trim().toLowerCase();

      _firstName =
          result["firstName"]?.toString() ??
          result["prenom"]?.toString() ??
          email.split('@')[0];

      _lastName =
          result["lastName"]?.toString() ?? result["nom"]?.toString() ?? "";

      _role = result["role"]?.toString().trim().toUpperCase();
      _userId = _parseInt(result["userId"]);
      _profilePicture = result["profilePicture"]?.toString();
      _nbDemandes = 0;

      if (_token == null ||
          _token!.isEmpty ||
          _role == null ||
          _role!.isEmpty) {
        _errorMessage = "Réponse serveur invalide";
        _isAuthenticated = false;
        return false;
      }

      _isAuthenticated = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", _token!);
      await prefs.setString("email", _email!);
      await prefs.setString("firstName", _firstName ?? "");
      await prefs.setString("lastName", _lastName ?? "");
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
      final normalizedRole = role.trim().toUpperCase();

      final result = await _api.register(
        nom: lastName.trim(),
        prenom: firstName.trim(),
        telephone: phone.trim(),
        email: email.trim().toLowerCase(),
        password: password,
        role: normalizedRole,
      );

      if (result["success"] != true) {
        _errorMessage =
            result["message"]?.toString() ?? "Erreur création compte";
        _isAuthenticated = false;
        return false;
      }

      _token = result["token"]?.toString();
      _email = email.trim().toLowerCase();

      _firstName =
          result["firstName"]?.toString() ??
          result["prenom"]?.toString() ??
          firstName.trim();

      _lastName =
          result["lastName"]?.toString() ??
          result["nom"]?.toString() ??
          lastName.trim();

      _role = result["role"]?.toString().trim().toUpperCase() ?? normalizedRole;
      _userId = _parseInt(result["userId"]);
      _profilePicture = result["profilePicture"]?.toString();
      _nbDemandes = 0;

      if (_token == null ||
          _token!.isEmpty ||
          _role == null ||
          _role!.isEmpty) {
        _errorMessage = "Réponse serveur invalide";
        _isAuthenticated = false;
        return false;
      }

      _isAuthenticated = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", _token!);
      await prefs.setString("email", _email!);
      await prefs.setString("firstName", _firstName ?? "");
      await prefs.setString("lastName", _lastName ?? "");
      await prefs.setString("role", _role!);
      if (_userId != null) await prefs.setInt("userId", _userId!);
      await prefs.setString("profilePicture", _profilePicture ?? "");
      await prefs.setBool("isAuth", true);

      return true;
    } catch (e) {
      _errorMessage = "Erreur lors de l'inscription";
      _isAuthenticated = false;
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
    final lastName = prefs.getString("lastName");
    final telephone = prefs.getString("telephone");
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
    _role = role.trim().toUpperCase();
    _userId = userId;
    _firstName = firstName;
    _lastName = lastName;
    _telephone = (telephone == null || telephone.isEmpty) ? null : telephone;
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

  Future<void> updateUserInfo({
    String? newName,
    String? newEmail,
    String? newLastName,
    String? newTelephone,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (newName != null && newName.trim().isNotEmpty) {
      _firstName = newName.trim();
      await prefs.setString("firstName", _firstName!);
    }

    if (newLastName != null && newLastName.trim().isNotEmpty) {
      _lastName = newLastName.trim();
      await prefs.setString("lastName", _lastName!);
    }

    if (newEmail != null && newEmail.trim().isNotEmpty) {
      _email = newEmail.trim().toLowerCase();
      await prefs.setString("email", _email!);
    }

    if (newTelephone != null && newTelephone.trim().isNotEmpty) {
      _telephone = newTelephone.trim();
      await prefs.setString("telephone", _telephone!);
    }

    notifyListeners();
  }

  Future<bool> updateProfile({
    required String prenom,
    required String nom,
    required String telephone,
  }) async {
    if (_token == null) return false;
    final ok = await _api.updateProfile(
      prenom: prenom,
      nom: nom,
      telephone: telephone,
      token: _token!,
    );
    if (ok) {
      await updateUserInfo(
        newName: prenom,
        newLastName: nom,
        newTelephone: telephone,
      );
    }
    return ok;
  }

  Future<bool> updatePassword(String currentPassword, String newPassword) async {
    if (_token == null) return false;
    try {
      return await _api.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        token: _token!,
      );
    } catch (_) {
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
    _lastName = null;
    _telephone = null;
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
    _lastName = null;
    _telephone = null;
    _userId = null;
    _errorMessage = null;
    _profilePicture = null;
    _nbDemandes = 0;

    notifyListeners();
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}
