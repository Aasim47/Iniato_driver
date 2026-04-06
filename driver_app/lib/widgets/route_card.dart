import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/route_model.dart';

/// Route summary card used in route history and active route lists.
class RouteCard extends StatelessWidget {
  final RouteModel route;
  final VoidCallback? onTap;

  const RouteCard({
    super.key,
    required this.route,
    this.onTap,
  });

  Color get _statusColor {
    switch (route.status) {
      case 'ACTIVE':
        return DriverTheme.online;
      case 'COMPLETED':
        return DriverTheme.accent;
      case 'CANCELLED':
        return DriverTheme.error;
      default:
        return DriverTheme.textSecondary;
    }
  }

  IconData get _statusIcon {
    switch (route.status) {
      case 'ACTIVE':
        return Icons.play_circle_filled;
      case 'COMPLETED':
        return Icons.check_circle;
      case 'CANCELLED':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DriverTheme.radiusMd),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Route ID + Status
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: DriverTheme.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.route,
                    color: DriverTheme.accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Route #${route.routeId}',
                        style: DriverTheme.body
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${route.occupiedSeats}/${route.totalSeats} passengers',
                        style: DriverTheme.caption,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon, size: 14, color: _statusColor),
                      const SizedBox(width: 4),
                      Text(
                        route.statusLabel,
                        style: TextStyle(
                          color: _statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Seats progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: route.totalSeats > 0
                    ? route.occupiedSeats / route.totalSeats
                    : 0,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(_statusColor),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 8),

            // Available seats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${route.availableSeats} seats available',
                  style: DriverTheme.caption.copyWith(fontSize: 12),
                ),
                if (onTap != null)
                  Row(
                    children: [
                      Text(
                        'View details',
                        style: TextStyle(
                          color: DriverTheme.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.chevron_right,
                          size: 16, color: DriverTheme.accent),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
