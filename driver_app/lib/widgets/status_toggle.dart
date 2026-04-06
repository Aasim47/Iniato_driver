import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Animated ONLINE / OFFLINE toggle for the driver dashboard.
class StatusToggle extends StatelessWidget {
  final bool isOnline;
  final bool isLoading;
  final ValueChanged<bool> onChanged;

  const StatusToggle({
    super.key,
    required this.isOnline,
    this.isLoading = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : () => onChanged(!isOnline),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isOnline
              ? const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                )
              : const LinearGradient(
                  colors: [Color(0xFFB71C1C), Color(0xFFE53935)],
                ),
          borderRadius: BorderRadius.circular(DriverTheme.radiusLg),
          boxShadow: [
            BoxShadow(
              color: (isOnline ? DriverTheme.online : DriverTheme.offline)
                  .withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            else
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  isOnline ? Icons.wifi : Icons.wifi_off,
                  key: ValueKey(isOnline),
                  color: Colors.white,
                  size: 20,
                ),
              ),
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                isOnline ? 'ONLINE' : 'OFFLINE',
                key: ValueKey(isOnline),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
