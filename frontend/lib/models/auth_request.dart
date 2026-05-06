class TokenRequest {
  final String email;
  final String password;

  TokenRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {"email": email.trim(), "password": password.trim()};
  }

  factory TokenRequest.fromJson(Map<String, dynamic> json) {
    return TokenRequest(
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }

  @override
  String toString() {
    return 'TokenRequest(email: $email)';
  }
}
