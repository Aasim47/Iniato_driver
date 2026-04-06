/// Driver profile returned by GET /api/driver/profile.
class DriverProfile {
  final String email;
  final String fullName;
  final String phoneNumber;
  final String vehicleRegistration;
  final String licenseNumber;
  final String status; // ONLINE or OFFLINE

  DriverProfile({
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.vehicleRegistration,
    required this.licenseNumber,
    required this.status,
  });

  factory DriverProfile.fromJson(Map<String, dynamic> json) {
    return DriverProfile(
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      vehicleRegistration: json['vehicleRegistration'] ?? '',
      licenseNumber: json['licenseNumber'] ?? '',
      status: json['status'] ?? 'OFFLINE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'vehicleRegistration': vehicleRegistration,
      'licenseNumber': licenseNumber,
    };
  }

  bool get isOnline => status == 'ONLINE';
}
