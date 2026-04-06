import 'dart:async';
import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/auth_service.dart';
import '../widgets/iniato_button.dart';
import 'main_nav_screen.dart';

/// OTP verification screen for driver login / registration.
class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isLogin;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.isLogin,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool isLoading = false;
  int _resendCountdown = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _resendCountdown = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _verifyOtp() async {
    final otp = _otp;
    if (otp.length < 6) {
      _showSnackBar('Please enter the full 6-digit OTP');
      return;
    }

    setState(() => isLoading = true);
    try {
      final authResponse = await AuthService.verifyOtp(
        widget.phoneNumber,
        otp,
        isLogin: widget.isLogin,
      );
      if (!mounted) return;
      if (authResponse != null || !widget.isLogin) {
        // For login, we get a token. For registration OTP, we just verified.
        if (widget.isLogin && authResponse != null) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainNavScreen()),
            (route) => false,
          );
        } else if (!widget.isLogin) {
          // Registration OTP verified — pop back to signup to complete
          Navigator.pop(context, true);
        }
      } else {
        _showSnackBar('Invalid OTP. Please try again.');
      }
    } catch (e) {
      _showSnackBar('Error verifying OTP');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_resendCountdown > 0) return;
    await AuthService.sendOtp(widget.phoneNumber, isLogin: widget.isLogin);
    _startTimer();
    if (mounted) _showSnackBar('OTP resent');
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: DriverTheme.accent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      size: 28,
                      color: DriverTheme.accent,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Verify OTP', style: DriverTheme.heading),
                  const SizedBox(height: 8),
                  Text(
                    'Enter the 6-digit code sent to',
                    style: DriverTheme.caption.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.phoneNumber,
                    style: DriverTheme.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: DriverTheme.accent,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // OTP Input boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (i) {
                      return SizedBox(
                        width: 44,
                        height: 52,
                        child: TextField(
                          controller: _controllers[i],
                          focusNode: _focusNodes[i],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: DriverTheme.primary,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: DriverTheme.accent.withOpacity(0.06),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: DriverTheme.accent.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: DriverTheme.accent,
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty && i < 5) {
                              _focusNodes[i + 1].requestFocus();
                            } else if (value.isEmpty && i > 0) {
                              _focusNodes[i - 1].requestFocus();
                            }
                            if (_otp.length == 6) {
                              _verifyOtp();
                            }
                          },
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  IniatoButton(
                    label: 'Verify',
                    onPressed: _verifyOtp,
                    isLoading: isLoading,
                    icon: Icons.verified,
                  ),
                  const SizedBox(height: 16),

                  // Resend
                  TextButton(
                    onPressed: _resendCountdown == 0 ? _resendOtp : null,
                    child: Text(
                      _resendCountdown > 0
                          ? 'Resend OTP in ${_resendCountdown}s'
                          : 'Resend OTP',
                      style: TextStyle(
                        color: _resendCountdown > 0
                            ? DriverTheme.textSecondary
                            : DriverTheme.accent,
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
    );
  }
}
