class TokenRequest {
  final String email;
  final String role;
  final String secret;

  TokenRequest({
    required this.email,
    required this.role,
    required this.secret,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'role': role,
      'secret': secret,
    };
  }
}