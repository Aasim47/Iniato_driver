import 'dart:convert';
import '../config/api_config.dart';
import '../models/driver_profile.dart';
import 'api_service.dart';

/// Manages driver profile and online/offline status.
class DriverService {
  /// Fetch the authenticated driver's profile.
  static Future<DriverProfile?> getProfile() async {
    final response = await ApiService.get(ApiConfig.driverProfile);
    if (response.statusCode == 200) {
      return DriverProfile.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  /// Update profile info (name, phone, vehicle, license).
  static Future<DriverProfile?> updateProfile({
    required String fullName,
    required String phoneNumber,
    required String vehicleRegistration,
    required String licenseNumber,
  }) async {
    final response = await ApiService.put(
      ApiConfig.driverProfile,
      body: {
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'vehicleRegistration': vehicleRegistration,
        'licenseNumber': licenseNumber,
      },
    );
    if (response.statusCode == 200) {
      return DriverProfile.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  /// Toggle driver status: ONLINE / OFFLINE.
  static Future<DriverProfile?> updateStatus(String status) async {
    final response = await ApiService.patch(
      '${ApiConfig.driverStatus}?status=$status',
    );
    if (response.statusCode == 200) {
      return DriverProfile.fromJson(jsonDecode(response.body));
    }
    return null;
  }
}
