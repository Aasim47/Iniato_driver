import 'dart:convert';
import '../config/api_config.dart';
import '../models/auth_response.dart';
import 'api_service.dart';

/// Handles driver authentication: OTP, login, register, logout, token.
class AuthService {
  // ─── OTP ───

  /// Send OTP for login or registration.
  static Future<bool> sendOtp(String phone, {required bool isLogin}) async {
    final path = isLogin ? ApiConfig.loginSendOtp : ApiConfig.registerSendOtp;
    final response = await ApiService.post(
      path,
      body: {'phoneNumber': phone},
      auth: false,
    );
    return response.statusCode == 200;
  }

  /// Verify OTP. Returns AuthResponse on success (for login), null on failure.
  static Future<AuthResponse?> verifyOtp(
    String phone,
    String otp, {
    required bool isLogin,
  }) async {
    final path =
        isLogin ? ApiConfig.loginVerifyOtp : ApiConfig.registerVerifyOtp;
    final response = await ApiService.post(
      path,
      body: {'phoneNumber': phone, 'otp': otp},
      auth: false,
    );
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      try {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('token')) {
          final authResponse = AuthResponse.fromJson(data);
          await ApiService.saveToken(authResponse.token);
          return authResponse;
        }
      } catch (_) {
        // OTP verified but no token (registration flow)
      }
    }
    return null;
  }

  // ─── Registration ───

  /// Register a new driver. Returns true on success.
  static Future<bool> registerDriver({
    required String phone,
    required String name,
    required String licenseNumber,
    required String vehicleDetails,
  }) async {
    final response = await ApiService.post(
      ApiConfig.registerDriver(phone),
      body: {
        'name': name,
        'licenseNumber': licenseNumber,
        'vehicleDetails': vehicleDetails,
      },
      auth: false,
    );
    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('token')) {
          await ApiService.saveToken(data['token']);
        }
      } catch (_) {}
      return true;
    }
    return false;
  }

  // ─── Logout ───

  static Future<void> logout() async {
    try {
      await ApiService.post(ApiConfig.logout);
    } catch (_) {}
    await ApiService.clearToken();
  }

  // ─── Token Check ───

  static Future<bool> isLoggedIn() => ApiService.isLoggedIn();
}
