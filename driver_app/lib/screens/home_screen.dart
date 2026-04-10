import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../config/theme.dart';
import '../models/driver_profile.dart';
import '../services/driver_service.dart';
import '../services/location_service.dart';
import '../widgets/status_toggle.dart';
import 'create_route_screen.dart';


/// Driver dashboard — map, online/offline toggle, start route button.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MapboxMap? _mapController;
  final LocationService _locationService = LocationService();
  gl.Position? _currentPosition;
  DriverProfile? _profile;
  bool _isOnline = false;
  bool _isTogglingStatus = false;
  bool _hasCenteredOnUser = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await DriverService.getProfile();
      if (mounted && profile != null) {
        setState(() {
          _profile = profile;
          _isOnline = profile.isOnline;
        });
      }
    } catch (_) {}
  }

  Future<void> _initLocation() async {
    final position = await _locationService.getCurrentPosition();
    if (position != null && mounted) {
      setState(() => _currentPosition = position);
      _flyToUser(position);
    }
    _locationService.startTracking(
      onPosition: (pos) {
        if (mounted) setState(() => _currentPosition = pos);
      },
    );
  }

  Future<void> _toggleStatus(bool online) async {
    setState(() => _isTogglingStatus = true);
    try {
      final updated =
          await DriverService.updateStatus(online ? 'ONLINE' : 'OFFLINE');
      if (mounted && updated != null) {
        setState(() {
          _profile = updated;
          _isOnline = updated.isOnline;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update status')),
        );
      }
    } finally {
      if (mounted) setState(() => _isTogglingStatus = false);
    }
  }

  void _onMapCreated(MapboxMap controller) {
    _mapController = controller;

    // Enable the blue location puck (dot) with pulsing ring
    _mapController?.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
        showAccuracyRing: true,
      ),
    );

    // If we already have the user's position, fly to it now
    if (_currentPosition != null && !_hasCenteredOnUser) {
      _flyToUser(_currentPosition!);
    }
  }

  /// Fly the map camera to the given position.
  void _flyToUser(gl.Position position) {
    if (_mapController == null) return;
    _hasCenteredOnUser = true;
    _mapController!.flyTo(
      CameraOptions(
        center: Point(
          coordinates: Position(
            position.longitude,
            position.latitude,
          ),
        ),
        zoom: 15.0,
      ),
      MapAnimationOptions(duration: 1500),
    );
  }

  Future<void> _centerOnUser() async {
    final pos = await _locationService.getCurrentPosition();
    if (pos != null) {
      if (mounted) setState(() => _currentPosition = pos);
      _flyToUser(pos);
    } else if (_currentPosition != null) {
      // Fallback to last known position
      _flyToUser(_currentPosition!);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location unavailable. Please check permissions.')),
        );
      }
    }
  }

  void _navigateToCreateRoute() {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Waiting for location...')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateRouteScreen(
          currentLat: _currentPosition!.latitude,
          currentLng: _currentPosition!.longitude,
          driverId: _profile?.driverId,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _locationService.dispose();
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
          // ─── Full-screen Map ───
          MapWidget(
            onMapCreated: _onMapCreated,
            cameraOptions: _currentPosition != null
                ? CameraOptions(
                    center: Point(
                      coordinates: Position(
                        _currentPosition!.longitude,
                        _currentPosition!.latitude,
                      ),
                    ),
                    zoom: 15.0,
                  )
                : CameraOptions(
                    // Default: center of India as fallback
                    center: Point(
                      coordinates: Position(78.9629, 20.5937),
                    ),
                    zoom: 5.0,
                  ),
          ),

          // ─── Top Bar: Status Toggle ───
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: Row(
              children: [
                StatusToggle(
                  isOnline: _isOnline,
                  isLoading: _isTogglingStatus,
                  onChanged: _toggleStatus,
                ),
                const Spacer(),
                // Location button
                FloatingActionButton.small(
                  heroTag: 'location',
                  backgroundColor: Colors.white,
                  elevation: 4,
                  onPressed: _centerOnUser,
                  child:
                      const Icon(Icons.my_location, color: DriverTheme.accent),
                ),
              ],
            ),
          ),

          // ─── Bottom Dashboard ───
          DraggableScrollableSheet(
            initialChildSize: 0.18,
            minChildSize: 0.18,
            maxChildSize: 0.40,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Drag handle
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

                    // Welcome + stats row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, ${_profile?.fullName ?? 'Driver'}',
                                style: DriverTheme.subheading,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isOnline
                                    ? 'You are online and visible to riders'
                                    : 'Go online to start accepting rides',
                                style: DriverTheme.caption,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: DriverTheme.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            _isOnline
                                ? Icons.directions_car
                                : Icons.directions_car_outlined,
                            color: DriverTheme.accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Quick stats
                    Row(
                      children: [
                        _buildStat(
                          Icons.route,
                          '0',
                          'Today\'s Routes',
                          DriverTheme.accent,
                        ),
                        const SizedBox(width: 12),
                        _buildStat(
                          Icons.people,
                          '0',
                          'Passengers',
                          DriverTheme.online,
                        ),
                        const SizedBox(width: 12),
                        _buildStat(
                          Icons.currency_rupee,
                          '₹0',
                          'Earnings',
                          DriverTheme.earnings,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          // ─── Start Route FAB ───
          if (_isOnline)
            Positioned(
              right: 16,
              bottom: 160,
              child: FloatingActionButton.extended(
                heroTag: 'create_route',
                onPressed: _navigateToCreateRoute,
                backgroundColor: DriverTheme.accent,
                icon: const Icon(Icons.add_road),
                label: const Text(
                  'Start Route',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: DriverTheme.caption.copyWith(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}