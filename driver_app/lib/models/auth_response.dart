/// JWT auth response from login / register.
class AuthResponse {
  final String token;
  final String phoneNumber;
  final String userType;

  AuthResponse({
    required this.token,
    required this.phoneNumber,
    required this.userType,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      userType: json['userType'] ?? 'DRIVER',
    );
  }
}
