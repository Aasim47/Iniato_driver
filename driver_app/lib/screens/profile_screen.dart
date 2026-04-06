import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/driver_profile.dart';
import '../services/auth_service.dart';
import '../services/driver_service.dart';
import '../widgets/iniato_button.dart';
import '../widgets/iniato_text_field.dart';
import '../widgets/status_toggle.dart';
import 'login_screen.dart';

/// Driver profile — view/edit info, status toggle, logout.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  DriverProfile? _profile;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isTogglingStatus = false;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final vehicleController = TextEditingController();
  final licenseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await DriverService.getProfile();
      if (mounted && profile != null) {
        setState(() {
          _profile = profile;
          nameController.text = profile.fullName;
          phoneController.text = profile.phoneNumber;
          vehicleController.text = profile.vehicleRegistration;
          licenseController.text = profile.licenseNumber;
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final updated = await DriverService.updateProfile(
        fullName: nameController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        vehicleRegistration: vehicleController.text.trim(),
        licenseNumber: licenseController.text.trim(),
      );
      if (mounted && updated != null) {
        setState(() {
          _profile = updated;
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated!')),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
    }
    if (mounted) setState(() => _isSaving = false);
  }

  Future<void> _toggleStatus(bool online) async {
    setState(() => _isTogglingStatus = true);
    try {
      final updated =
          await DriverService.updateStatus(online ? 'ONLINE' : 'OFFLINE');
      if (mounted && updated != null) {
        setState(() => _profile = updated);
      }
    } catch (_) {}
    if (mounted) setState(() => _isTogglingStatus = false);
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout?'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: DriverTheme.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await AuthService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: DriverTheme.primary,
        automaticallyImplyLeading: false,
        actions: [
          if (_profile != null && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // ─── Avatar & Status ───
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: DriverTheme.backgroundGradient,
                      borderRadius:
                          BorderRadius.circular(DriverTheme.radiusLg),
                      boxShadow: DriverTheme.elevatedShadow,
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _profile?.fullName ?? 'Driver',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _profile?.email ?? '',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        StatusToggle(
                          isOnline: _profile?.isOnline ?? false,
                          isLoading: _isTogglingStatus,
                          onChanged: _toggleStatus,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ─── Profile Fields ───
                  if (_isEditing) ...[
                    IniatoTextField(
                      controller: nameController,
                      label: 'Full Name',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 16),
                    IniatoTextField(
                      controller: phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    IniatoTextField(
                      controller: vehicleController,
                      label: 'Vehicle Registration',
                      icon: Icons.directions_car,
                    ),
                    const SizedBox(height: 16),
                    IniatoTextField(
                      controller: licenseController,
                      label: 'License Number',
                      icon: Icons.badge,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: IniatoButton(
                            label: 'Cancel',
                            isOutlined: true,
                            onPressed: () {
                              setState(() => _isEditing = false);
                              // Reset fields
                              nameController.text = _profile?.fullName ?? '';
                              phoneController.text =
                                  _profile?.phoneNumber ?? '';
                              vehicleController.text =
                                  _profile?.vehicleRegistration ?? '';
                              licenseController.text =
                                  _profile?.licenseNumber ?? '';
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: IniatoButton(
                            label: 'Save',
                            onPressed: _saveProfile,
                            isLoading: _isSaving,
                            icon: Icons.save,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    _buildInfoTile(Icons.phone, 'Phone',
                        _profile?.phoneNumber ?? ''),
                    _buildInfoTile(Icons.directions_car, 'Vehicle',
                        _profile?.vehicleRegistration ?? ''),
                    _buildInfoTile(Icons.badge, 'License',
                        _profile?.licenseNumber ?? ''),
                  ],
                  const SizedBox(height: 32),

                  // ─── Logout ───
                  IniatoButton(
                    label: 'Logout',
                    onPressed: _logout,
                    isOutlined: true,
                    color: DriverTheme.error,
                    icon: Icons.logout,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DriverTheme.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: DriverTheme.accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: DriverTheme.accent, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: DriverTheme.caption.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? '—' : value,
                style: DriverTheme.body.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
