import 'dart:async';
import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import '../config/api_config.dart';

/// STOMP WebSocket service for broadcasting driver location in real-time.
class WebSocketService {
  StompClient? _client;
  bool _isConnected = false;

  /// Whether the WebSocket is currently connected.
  bool get isConnected => _isConnected;

  /// Connect to the WebSocket endpoint.
  void connect({void Function()? onConnected}) {
    _client = StompClient(
      config: StompConfig.sockJS(
        url: ApiConfig.wsUrl,
        onConnect: (StompFrame frame) {
          _isConnected = true;
          onConnected?.call();
        },
        onWebSocketError: (error) {
          // WebSocket error
        },
        onStompError: (frame) {
          // STOMP error
        },
        onDisconnect: (frame) {
          _isConnected = false;
        },
      ),
    );
    _client!.activate();
  }

  /// Send driver location update to server.
  /// The server broadcasts this to passengers subscribed to the ride.
  void sendLocationUpdate({
    required int driverId,
    required double latitude,
    required double longitude,
    required int rideId,
  }) {
    if (_client == null || !_isConnected) return;

    _client!.send(
      destination: '/app/driver/updateLocation',
      body: jsonEncode({
        'driverId': driverId,
        'latitude': latitude,
        'longitude': longitude,
        'rideId': rideId,
      }),
    );
  }

  /// Subscribe to ride updates (optional — for listening to ride status).
  void subscribeToRide(
    int rideId,
    void Function(Map<String, dynamic> data) onData,
  ) {
    if (_client == null || !_isConnected) return;

    _client!.subscribe(
      destination: '/topic/ride/$rideId',
      callback: (frame) {
        if (frame.body != null) {
          try {
            final data = jsonDecode(frame.body!) as Map<String, dynamic>;
            onData(data);
          } catch (_) {
            // Parse error
          }
        }
      },
    );
  }

  /// Disconnect and clean up.
  void disconnect() {
    _client?.deactivate();
    _client = null;
    _isConnected = false;
  }

  void dispose() => disconnect();
}
