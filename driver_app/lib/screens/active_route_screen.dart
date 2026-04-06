import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../config/theme.dart';
import '../models/route_model.dart';
import '../models/ride.dart';
import '../services/location_service.dart';
import '../services/route_service.dart';
import '../services/websocket_service.dart';
import '../widgets/iniato_button.dart';
import '../widgets/passenger_card.dart';

/// Live route tracking — shows map, passenger list, and route controls.
class ActiveRouteScreen extends StatefulWidget {
  final RouteModel route;

  const ActiveRouteScreen({super.key, required this.route});

  @override
  State<ActiveRouteScreen> createState() => _ActiveRouteScreenState();
}

class _ActiveRouteScreenState extends State<ActiveRouteScreen> {
  MapboxMap? _mapController;
  final LocationService _locationService = LocationService();
  final WebSocketService _wsService = WebSocketService();
  gl.Position? _currentPosition;
  late RouteModel _route;
  Timer? _locationUpdateTimer;
  List<RidePassenger> _passengers = [];
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _route = widget.route;
    _initTracking();
    _connectWebSocket();
  }

  Future<void> _initTracking() async {
    final position = await _locationService.getCurrentPosition();
    if (position != null && mounted) {
      setState(() => _currentPosition = position);
    }

    // Start continuous tracking
    _locationService.startTracking(
      distanceFilter: 20,
      onPosition: (pos) {
        if (mounted) {
          setState(() => _currentPosition = pos);
          _sendLocationUpdate(pos);
        }
      },
    );

    // Also send location periodically (every 10s)
    _locationUpdateTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) {
        if (_currentPosition != null) {
          _sendLocationUpdate(_currentPosition!);
          // Also update via REST endpoint
          RouteService.updateLocation(
            _route.routeId,
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          );
        }
      },
    );
  }

  void _connectWebSocket() {
    _wsService.connect(onConnected: () {
      // Subscribe to ride updates if we have a rideId
      if (_route.rideId != null) {
        _wsService.subscribeToRide(_route.rideId!, (data) {
          // Handle incoming ride update (e.g., new passenger joined)
          if (mounted) {
            // Refresh passengers from data if available
            if (data.containsKey('passengers')) {
              final passengerList = (data['passengers'] as List?)
                      ?.map((p) => RidePassenger.fromJson(p))
                      .toList() ??
                  [];
              setState(() => _passengers = passengerList);
            }
          }
        });
      }
    });
  }

  void _sendLocationUpdate(gl.Position pos) {
    if (_wsService.isConnected) {
      _wsService.sendLocationUpdate(
        driverId: 0, // Will be resolved server-side from auth
        latitude: pos.latitude,
        longitude: pos.longitude,
        rideId: _route.rideId ?? 0,
      );
    }
  }

  Future<void> _completeRoute() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Complete Route?'),
        content:
            const Text('Are you sure you want to end this route? All passengers should have been dropped off.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: DriverTheme.accent,
            ),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isCompleting = true);
    try {
      final updated = await RouteService.completeRoute(_route.routeId);
      if (!mounted) return;
      if (updated != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Route completed successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error completing route')),
      );
    } finally {
      if (mounted) setState(() => _isCompleting = false);
    }
  }

  Future<void> _confirmCashPayment(RidePassenger passenger) async {
    if (passenger.passengerId == null || _route.rideId == null) return;
    try {
      final success = await RouteService.confirmCashPayment(
        _route.rideId!,
        passenger.passengerId!,
      );
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Cash confirmed for ${passenger.name ?? "passenger"}')),
        );
      }
    } catch (_) {}
  }

  void _onMapCreated(MapboxMap controller) {
    _mapController = controller;
    _mapController?.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
      ),
    );
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    _locationService.dispose();
    _wsService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const Scaffold(
        body: Center(child: Text('Please run on Android or iOS')),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Map
          MapWidget(onMapCreated: _onMapCreated),

          // Top bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(DriverTheme.radiusMd),
                boxShadow: DriverTheme.cardShadow,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back,
                        color: DriverTheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Route #${_route.routeId}',
                          style: DriverTheme.body
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${_route.occupiedSeats}/${_route.totalSeats} passengers',
                          style: DriverTheme.caption.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: DriverTheme.online.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: DriverTheme.online,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'LIVE',
                          style: TextStyle(
                            color: DriverTheme.online,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom panel
          DraggableScrollableSheet(
            initialChildSize: 0.30,
            minChildSize: 0.15,
            maxChildSize: 0.65,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Route info
                    Row(
                      children: [
                        Icon(Icons.route, color: DriverTheme.accent, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Active Route',
                          style: DriverTheme.subheading.copyWith(fontSize: 16),
                        ),
                        const Spacer(),
                        Text(
                          '${_route.availableSeats} seats left',
                          style: DriverTheme.caption,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Passengers
                    if (_passengers.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: DriverTheme.accent.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.people_outline,
                                color: DriverTheme.textSecondary, size: 36),
                            const SizedBox(height: 8),
                            Text(
                              'No passengers yet',
                              style: DriverTheme.caption,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Riders nearby will be matched to your route',
                              style: DriverTheme.caption.copyWith(fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      ..._passengers.map(
                        (p) => PassengerCard(
                          name: p.name,
                          phone: p.phone,
                          pickupLocation: p.pickupLocation,
                          dropLocation: p.dropLocation,
                          status: p.status,
                          onConfirmCash: () => _confirmCashPayment(p),
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Complete button
                    IniatoButton(
                      label: 'Complete Route',
                      onPressed: _completeRoute,
                      isLoading: _isCompleting,
                      icon: Icons.check_circle,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
