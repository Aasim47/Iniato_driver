import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../widgets/route_card.dart';
import '../models/route_model.dart';

/// Shows past completed routes.
class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  bool _isLoading = false;
  final List<RouteModel> _routes = [];

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    setState(() => _isLoading = true);
    // TODO: Add a GET /api/routes/my endpoint on backend for driver's routes
    // For now, show an empty state
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Routes'),
        backgroundColor: DriverTheme.primary,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _loadRoutes,
        color: DriverTheme.accent,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _routes.isEmpty
                ? ListView(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: DriverTheme.accent.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.route_outlined,
                                  size: 40,
                                  color: DriverTheme.accent.withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Routes Yet',
                                style: DriverTheme.subheading.copyWith(
                                  color: DriverTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Your completed routes will appear here',
                                style: DriverTheme.caption,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _routes.length,
                    itemBuilder: (context, index) {
                      return RouteCard(
                        route: _routes[index],
                        onTap: () {
                          // Could navigate to route details
                        },
                      );
                    },
                  ),
      ),
    );
  }
}
