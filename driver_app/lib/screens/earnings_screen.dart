import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Earnings dashboard — completed rides and earnings summary.
class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  // Will be populated from backend in the future
  final double _todayEarnings = 0;
  final double _weekEarnings = 0;
  final double _monthEarnings = 0;
  final int _todayTrips = 0;
  final int _totalPassengers = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
        backgroundColor: DriverTheme.primary,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Today's Summary Card ───
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: DriverTheme.backgroundGradient,
                borderRadius: BorderRadius.circular(DriverTheme.radiusLg),
                boxShadow: DriverTheme.elevatedShadow,
              ),
              child: Column(
                children: [
                  const Text(
                    "Today's Earnings",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${_todayEarnings.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 1,
                    color: Colors.white.withOpacity(0.15),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMiniStat(
                          Icons.route, '$_todayTrips', 'Trips'),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      _buildMiniStat(
                          Icons.people, '$_totalPassengers', 'Riders'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ─── Period Earnings ───
            Text('Earnings Overview', style: DriverTheme.subheading),
            const SizedBox(height: 16),

            _buildEarningsPeriod(
              'This Week',
              _weekEarnings,
              Icons.calendar_view_week,
              DriverTheme.accent,
            ),
            _buildEarningsPeriod(
              'This Month',
              _monthEarnings,
              Icons.calendar_month,
              DriverTheme.earnings,
            ),
            const SizedBox(height: 24),

            // ─── Recent Transactions ───
            Text('Recent Transactions', style: DriverTheme.subheading),
            const SizedBox(height: 16),

            // Empty state
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: DriverTheme.accent.withOpacity(0.04),
                borderRadius: BorderRadius.circular(DriverTheme.radiusMd),
                border: Border.all(
                    color: DriverTheme.accent.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 40,
                    color: DriverTheme.textSecondary.withOpacity(0.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No transactions yet',
                    style: DriverTheme.caption.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Complete rides to see your earnings here',
                    style: DriverTheme.caption.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEarningsPeriod(
    String label,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DriverTheme.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: DriverTheme.body),
                const SizedBox(height: 2),
                Text(
                  'View breakdown →',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
