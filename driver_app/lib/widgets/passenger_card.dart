import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Card showing passenger info during an active ride.
class PassengerCard extends StatelessWidget {
  final String? name;
  final String? phone;
  final String? pickupLocation;
  final String? dropLocation;
  final String status;
  final VoidCallback? onConfirmCash;

  const PassengerCard({
    super.key,
    this.name,
    this.phone,
    this.pickupLocation,
    this.dropLocation,
    required this.status,
    this.onConfirmCash,
  });

  Color get _statusColor {
    switch (status) {
      case 'PICKED_UP':
        return DriverTheme.online;
      case 'DROPPED_OFF':
        return DriverTheme.accent;
      default:
        return DriverTheme.warning;
    }
  }

  String get _statusLabel {
    switch (status) {
      case 'PICKED_UP':
        return 'Picked up';
      case 'DROPPED_OFF':
        return 'Dropped off';
      default:
        return 'Waiting';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DriverTheme.radiusMd),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: DriverTheme.accent.withOpacity(0.12),
                child: Icon(
                  Icons.person,
                  color: DriverTheme.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name ?? 'Passenger',
                      style: DriverTheme.body
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (phone != null)
                      Text(phone!, style: DriverTheme.caption),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusLabel,
                  style: TextStyle(
                    color: _statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (pickupLocation != null || dropLocation != null) ...[
            const SizedBox(height: 10),
            if (pickupLocation != null)
              _buildLocationRow(
                Icons.trip_origin,
                pickupLocation!,
                DriverTheme.online,
              ),
            if (dropLocation != null)
              _buildLocationRow(
                Icons.location_on,
                dropLocation!,
                DriverTheme.offline,
              ),
          ],
          if (onConfirmCash != null && status != 'DROPPED_OFF') ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onConfirmCash,
                icon: const Icon(Icons.payments, size: 18),
                label: const Text('Confirm Cash'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: DriverTheme.online,
                  side: const BorderSide(color: DriverTheme.online),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: DriverTheme.caption.copyWith(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
