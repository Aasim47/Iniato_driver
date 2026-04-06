import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/auth_service.dart';
import '../widgets/iniato_button.dart';
import '../widgets/iniato_text_field.dart';
import 'otp_screen.dart';
import 'main_nav_screen.dart';

/// Multi-step driver registration: Phone → OTP → Driver details.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final nameController = TextEditingController();
  final licenseController = TextEditingController();
  final vehicleController = TextEditingController();

  int _step = 0; // 0: phone, 1: driver details
  bool isLoading = false;

  Future<void> _sendOtp() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      _showSnackBar('Please enter a phone number');
      return;
    }

    setState(() => isLoading = true);
    try {
      final success = await AuthService.sendOtp(phone, isLogin: false);
      if (!mounted) return;
      if (success) {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) =>
                OtpScreen(phoneNumber: phone, isLogin: false),
          ),
        );
        if (result == true && mounted) {
          setState(() {
            _step = 1;
          });
        }
      } else {
        _showSnackBar('Failed to send OTP');
      }
    } catch (e) {
      _showSnackBar('Error connecting to server');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _completeRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      final success = await AuthService.registerDriver(
        phone: phoneController.text.trim(),
        name: nameController.text.trim(),
        licenseNumber: licenseController.text.trim(),
        vehicleDetails: vehicleController.text.trim(),
      );
      if (!mounted) return;
      if (success) {
        _showSnackBar('Registration successful!');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainNavScreen()),
          (route) => false,
        );
      } else {
        _showSnackBar('Registration failed. Please try again.');
      }
    } catch (e) {
      _showSnackBar('Error connecting to server');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration:
            const BoxDecoration(gradient: DriverTheme.backgroundGradient),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: DriverTheme.cardDecoration,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: DriverTheme.accent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _step == 0
                            ? Icons.phone_android
                            : Icons.badge_outlined,
                        size: 32,
                        color: DriverTheme.accent,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _step == 0 ? 'Create Account' : 'Driver Details',
                      style: DriverTheme.heading,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _step == 0
                          ? 'Verify your phone to get started'
                          : 'Enter your driver information',
                      style: DriverTheme.caption.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 8),

                    // Step indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDot(0),
                        Container(
                          width: 32,
                          height: 2,
                          color: _step >= 1
                              ? DriverTheme.accent
                              : Colors.grey.shade300,
                        ),
                        _buildDot(1),
                      ],
                    ),
                    const SizedBox(height: 24),

                    if (_step == 0) ...[
                      IniatoTextField(
                        controller: phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 24),
                      IniatoButton(
                        label: 'Verify Phone',
                        onPressed: _sendOtp,
                        isLoading: isLoading,
                        icon: Icons.sms,
                      ),
                    ] else ...[
                      IniatoTextField(
                        controller: nameController,
                        label: 'Full Name',
                        icon: Icons.person,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Name required' : null,
                      ),
                      const SizedBox(height: 16),
                      IniatoTextField(
                        controller: licenseController,
                        label: 'License Number',
                        icon: Icons.badge,
                        validator: (v) => v == null || v.isEmpty
                            ? 'License required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      IniatoTextField(
                        controller: vehicleController,
                        label: 'Vehicle Details',
                        icon: Icons.directions_car,
                        validator: (v) => v == null || v.isEmpty
                            ? 'Vehicle details required'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      IniatoButton(
                        label: 'Complete Registration',
                        onPressed: _completeRegistration,
                        isLoading: isLoading,
                        icon: Icons.check_circle,
                      ),
                    ],

                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Already have an account? Login',
                        style: TextStyle(
                          color: DriverTheme.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDot(int step) {
    final isActive = _step >= step;
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? DriverTheme.accent : Colors.grey.shade300,
      ),
    );
  }
}
