import 'dart:convert';
import '../config/api_config.dart';
import '../models/route_model.dart';
import 'api_service.dart';

/// Manages route CRUD and payment confirmations for the driver.
class RouteService {
  /// Declare a new route.
  static Future<RouteModel?> createRoute({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
    required int totalSeats,
  }) async {
    final response = await ApiService.post(
      ApiConfig.createRoute,
      body: {
        'originLat': originLat,
        'originLng': originLng,
        'destinationLat': destinationLat,
        'destinationLng': destinationLng,
        'totalSeats': totalSeats,
      },
    );
    if (response.statusCode == 200) {
      return RouteModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  /// Update the driver's current location on a route.
  static Future<bool> updateLocation(int routeId, double lat, double lng) async {
    final response = await ApiService.patch(
      ApiConfig.updateRouteLocation(routeId),
      body: {'lat': lat, 'lng': lng},
    );
    return response.statusCode == 200;
  }

  /// Add a pickup/drop stop to a route.
  static Future<RouteModel?> addStop({
    required int routeId,
    required double lat,
    required double lng,
    required String type, // PICKUP or DROP
    required int sequenceOrder,
  }) async {
    final response = await ApiService.patch(
      ApiConfig.addRouteStop(routeId),
      body: {
        'lat': lat,
        'lng': lng,
        'type': type,
        'sequenceOrder': sequenceOrder,
      },
    );
    if (response.statusCode == 200) {
      return RouteModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  /// Mark a route as completed.
  static Future<RouteModel?> completeRoute(int routeId) async {
    final response = await ApiService.patch(
      ApiConfig.completeRoute(routeId),
    );
    if (response.statusCode == 200) {
      return RouteModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  /// Confirm cash payment received from a passenger.
  static Future<bool> confirmCashPayment(int rideId, int passengerId) async {
    final response = await ApiService.post(
      ApiConfig.confirmCashPayment(rideId, passengerId),
    );
    return response.statusCode == 200;
  }
}
