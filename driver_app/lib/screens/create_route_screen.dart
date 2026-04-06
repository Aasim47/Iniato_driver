import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/theme.dart';
import '../services/route_service.dart';
import '../widgets/iniato_button.dart';
import 'active_route_screen.dart';

/// Screen to declare a new route — origin, destination, seats.
class CreateRouteScreen extends StatefulWidget {
  final double currentLat;
  final double currentLng;

  const CreateRouteScreen({
    super.key,
    required this.currentLat,
    required this.currentLng,
  });

  @override
  State<CreateRouteScreen> createState() => _CreateRouteScreenState();
}

class _CreateRouteScreenState extends State<CreateRouteScreen> {
  final _destinationController = TextEditingController();

  int _totalSeats = 3;
  bool _isLoading = false;
  bool _isSearching = false;

  // Origin / Destination coordinates
  late final double _originLat = widget.currentLat;
  late final double _originLng = widget.currentLng;
  final String _originLabel = 'Current Location';
  double? _destLat;
  double? _destLng;
  String _destLabel = '';

  // Search results
  List<Map<String, dynamic>> _searchResults = [];

  Future<void> _searchDestination(String query) async {
    if (query.length < 3) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);
    try {
      final url = Uri.parse(
        '${ApiConfig.mapboxGeocodingBase}/${Uri.encodeComponent(query)}.json'
        '?access_token=${ApiConfig.mapboxToken}'
        '&proximity=${widget.currentLng},${widget.currentLat}'
        '&limit=5',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final features = data['features'] as List<dynamic>? ?? [];
        setState(() {
          _searchResults = features.map<Map<String, dynamic>>((f) {
            final coords = f['center'] as List;
            return {
              'name': f['place_name'] ?? '',
              'lng': coords[0],
              'lat': coords[1],
            };
          }).toList();
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _isSearching = false);
  }

  void _selectDestination(Map<String, dynamic> place) {
    setState(() {
      _destLat = place['lat'];
      _destLng = place['lng'];
      _destLabel = place['name'];
      _destinationController.text = place['name'];
      _searchResults = [];
    });
  }

  Future<void> _createRoute() async {
    if (_destLat == null || _destLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a destination')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final route = await RouteService.createRoute(
        originLat: _originLat,
        originLng: _originLng,
        destinationLat: _destLat!,
        destinationLng: _destLng!,
        totalSeats: _totalSeats,
      );
      if (!mounted) return;
      if (route != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ActiveRouteScreen(route: route),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create route')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error connecting to server')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Route'),
        backgroundColor: DriverTheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Origin ───
            Text('Origin', style: DriverTheme.subheading),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DriverTheme.accent.withOpacity(0.06),
                borderRadius: BorderRadius.circular(DriverTheme.radiusMd),
                border: Border.all(color: DriverTheme.accent.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.trip_origin, color: DriverTheme.online, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _originLabel,
                      style: DriverTheme.body,
                    ),
                  ),
                  Icon(Icons.my_location,
                      color: DriverTheme.accent, size: 18),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ─── Destination ───
            Text('Destination', style: DriverTheme.subheading),
            const SizedBox(height: 8),
            TextField(
              controller: _destinationController,
              style: DriverTheme.body,
              decoration: DriverTheme.inputDecoration(
                'Search destination',
                icon: Icons.location_on,
              ),
              onChanged: _searchDestination,
            ),

            // Search results dropdown
            if (_searchResults.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: DriverTheme.cardShadow,
                ),
                child: Column(
                  children: _searchResults.map((place) {
                    return ListTile(
                      leading: const Icon(Icons.place,
                          color: DriverTheme.accent, size: 20),
                      title: Text(
                        place['name'],
                        style: DriverTheme.body.copyWith(fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      dense: true,
                      onTap: () => _selectDestination(place),
                    );
                  }).toList(),
                ),
              ),

            if (_isSearching)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),

            if (_destLabel.isNotEmpty && _searchResults.isEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DriverTheme.online.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: DriverTheme.online, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _destLabel,
                        style: DriverTheme.caption.copyWith(
                          color: DriverTheme.online,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 28),

            // ─── Seats ───
            Text('Available Seats', style: DriverTheme.subheading),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSeatButton(Icons.remove, () {
                  if (_totalSeats > 1) setState(() => _totalSeats--);
                }),
                const SizedBox(width: 24),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: DriverTheme.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      '$_totalSeats',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: DriverTheme.accent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                _buildSeatButton(Icons.add, () {
                  if (_totalSeats < 8) setState(() => _totalSeats++);
                }),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Max passengers your vehicle can carry',
                style: DriverTheme.caption,
              ),
            ),
            const SizedBox(height: 32),

            // ─── Create Button ───
            IniatoButton(
              label: 'Start Route',
              onPressed: _createRoute,
              isLoading: _isLoading,
              icon: Icons.play_arrow,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: DriverTheme.accent.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: DriverTheme.accent),
      ),
    );
  }
}
