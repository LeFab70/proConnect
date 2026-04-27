import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl =
      "https://proconnectnb-d2bxe6embxg2e7h7.eastus2-01.azurewebsites.net";

  Future<Map<String, dynamic>?> login(
      String email, String role, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/auth/login"), 
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode({
          "email": email,
          "role": role,
          "secret": password,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("❌ Login error: ${response.body}");
        return null;
      }
    } catch (e) {
      print("🔥 Exception login: $e");
      return null;
    }
  }
}