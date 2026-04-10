/// Centralized API configuration for the Iniato Driver app.
/// Change [baseUrl] to match your backend server address.
class ApiConfig {
  // ─── Base URLs ──────────────────────────────────────────────────────────
  // Emulator : 'http://10.0.2.2:8081'
  // Real device : 'http://192.168.31.119:8081'
  // Windows desktop : 'http://localhost:8081'
  static const String baseUrl = 'http://192.168.33.99:8081';

  // WebSocket (STOMP over SockJS)
  static const String wsUrl = 'ws://192.168.33.99:8081/ws/driver-location';

  // Mapbox
  static const String mapboxToken =
      'pk.eyJ1IjoiaW10aWZheiIsImEiOiJjbWprN3U3bGUwMTJ1M2twZ2s3bG45MWFpIn0.hNw5ey_P0O2t2VPMw-Ss2A';
  static const String mapboxGeocodingBase =
      'https://api.mapbox.com/geocoding/v5/mapbox.places';

  // ─── Auth ───────────────────────────────────────────────────────────────
  static const String registerSendOtp = '/api/auth/register/driver/send-otp';
  static const String registerVerifyOtp =
      '/api/auth/register/driver/verify-otp';
  static String registerDriver(String phone) =>
      '/api/auth/register/driver/$phone';
  static const String loginSendOtp = '/api/auth/login/send-otp';
  static const String loginVerifyOtp = '/api/auth/login/verify-otp';
  static const String logout = '/api/auth/logout';

  // ─── Driver Profile ────────────────────────────────────────────────────
  static const String driverProfile = '/api/driver/profile';
  static const String driverStatus = '/api/driver/status';

  // ─── Routes ─────────────────────────────────────────────────────────────
  static const String createRoute = '/api/routes';
  static String updateRouteLocation(int routeId) =>
      '/api/routes/$routeId/update-location';
  static String addRouteStop(int routeId) => '/api/routes/$routeId/add-stop';
  static String completeRoute(int routeId) =>
      '/api/routes/$routeId/complete';

  // ─── Payments ───────────────────────────────────────────────────────────
  static String confirmCashPayment(int rideId, int passengerId) =>
      '/api/payments/cash/confirm/$rideId/$passengerId';

  // ─── Safety ─────────────────────────────────────────────────────────────
  static const String emergencyContact = '/api/safety/emergency-contact';
  static const String sos = '/api/safety/sos';
  static String shareTrip(int rideId) => '/api/safety/share-trip/$rideId';
}
