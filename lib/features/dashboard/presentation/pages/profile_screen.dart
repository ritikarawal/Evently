import 'dart:io';

import 'package:event_planner/core/api/api_endpoints.dart';
import 'package:event_planner/features/auth/domain/entities/auth_entity.dart';
import 'package:event_planner/features/auth/domain/entities/update_profile_params.dart';
import 'package:event_planner/features/auth/presentation/pages/login_screen.dart';
import 'package:event_planner/features/auth/presentation/state/auth_state.dart';
import 'package:event_planner/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:event_planner/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  bool _isSavingProfile = false;
  bool _isEditFormVisible = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    // Always fetch current user to ensure we have the latest data
    Future.microtask(() {
      final authViewModel = ref.read(authViewModelProvider.notifier);
      authViewModel.getCurrentUser();
    });
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    }

    final result = await permission.request();
    return result.isGranted;
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      // Request appropriate permission
      Permission permission;
      if (source == ImageSource.camera) {
        permission = Permission.camera;
      } else {
        // Use photos permission for gallery
        permission = Permission.photos;
      }

      // Check and request permission
      bool hasPermission = await _requestPermission(permission);

      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                source == ImageSource.camera
                    ? 'Camera permission is required'
                    : 'Gallery permission is required',
              ),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () {
                  openAppSettings();
                },
              ),
            ),
          );
        }
        return;
      }

      // Pick image
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        // Show loading indicator
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) =>
                const Center(child: CircularProgressIndicator()),
          );
        }

        final authViewModel = ref.read(authViewModelProvider.notifier);
        await authViewModel.updateProfilePicture(File(image.path));

        // Close loading dialog
        if (mounted) {
          Navigator.of(context).pop();

          final authState = ref.read(authViewModelProvider);
          if (authState.status == AuthStatus.authenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile picture updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (authState.status == AuthStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  authState.errorMessage ?? 'Failed to update profile picture',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      // Close loading dialog if open
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Choose Profile Picture',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.camera_alt, color: AppColors.primary),
              ),
              title: const Text(
                'Take Photo',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.photo_library,
                  color: AppColors.primary,
                ),
              ),
              title: const Text(
                'Choose from Gallery',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final authViewModel = ref.read(authViewModelProvider.notifier);
    final user = authState.user;

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      final nextUser = next.user;
      if (nextUser != null && nextUser != previous?.user) {
        _populateProfileFields(nextUser);
      }
    });
    if (user != null && _firstNameController.text.isEmpty) {
      _populateProfileFields(user);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        backgroundColor: AppColors.background,
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // User Header Card
              if (user != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Picture with Edit Button
                      Stack(
                        children: [
                          // Profile Picture
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: AppColors.primaryLight,
                              backgroundImage:
                                  user.profilePicture != null &&
                                      user.profilePicture!.isNotEmpty
                                  ? CachedNetworkImageProvider(
                                      ApiEndpoints.getImageUrl(
                                        user.profilePicture,
                                      ),
                                    )
                                  : null,
                              child:
                                  user.profilePicture == null ||
                                      user.profilePicture!.isEmpty
                                  ? Text(
                                      user.fullName.isNotEmpty
                                          ? user.fullName[0].toUpperCase()
                                          : "U",
                                      style: const TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          // Edit Button
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _showImageSourceDialog,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.cardBackground,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              const SizedBox(height: 24),
              if (user != null) ...[
                _isEditFormVisible
                    ? _buildEditProfileSection()
                    : _buildEditProfileButton(),
                const SizedBox(height: 24),
              ],
              // Information Section
              const Text(
                'Account Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              if (user != null)
                Column(
                  children: [
                    _buildInfoCard(
                      icon: Icons.person,
                      label: 'Full Name',
                      value: user.fullName,
                    ),
                    const SizedBox(height: 10),
                    _buildInfoCard(
                      icon: Icons.email,
                      label: 'Email',
                      value: user.email,
                    ),
                    const SizedBox(height: 10),
                    _buildInfoCard(
                      icon: Icons.account_circle,
                      label: 'Username',
                      value: user.username,
                    ),
                    if (user.phoneNumber != null &&
                        user.phoneNumber!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _buildInfoCard(
                        icon: Icons.phone,
                        label: 'Phone',
                        value: user.phoneNumber!,
                      ),
                    ],
                  ],
                ),
              const SizedBox(height: 28),
              // Statistics Section
              Row(
                children: [
                  Expanded(child: _buildStatCard('Events', '12')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Attending', '8')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Created', '4')),
                ],
              ),
              const SizedBox(height: 28),
              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              authViewModel.logout();
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                                (route) => false,
                              );
                            },
                            child: const Text(
                              'Logout',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout, size: 20),
                  label: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_isSavingProfile) return;
    if (_formKey.currentState?.validate() != true) return;

    FocusScope.of(context).unfocus();
    final params = UpdateProfileParams(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      password: _passwordController.text.isEmpty
          ? null
          : _passwordController.text,
    );

    setState(() => _isSavingProfile = true);
    final authViewModel = ref.read(authViewModelProvider.notifier);
    final success = await authViewModel.updateProfile(params);

    if (!mounted) return;
    setState(() => _isSavingProfile = false);

    final currentState = ref.read(authViewModelProvider);
    final message = success
        ? 'Profile updated successfully'
        : currentState.errorMessage ?? 'Failed to update profile';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));

    if (success) {
      setState(() => _isEditFormVisible = false);
      _passwordController.clear();
      _confirmPasswordController.clear();
    } else {
      authViewModel.clearError();
    }
  }

  void _populateProfileFields(AuthEntity user) {
    final nameParts = user.fullName.trim().split(RegExp(r'\s+'));
    _firstNameController.text = nameParts.isNotEmpty ? nameParts.first : '';
    _lastNameController.text = nameParts.length > 1
        ? nameParts.sublist(1).join(' ')
        : '';
    _usernameController.text = user.username;
    _emailController.text = user.email;
    _phoneController.text = user.phoneNumber ?? '';
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEditProfileButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            _isEditFormVisible = true;
          });
        },
        icon: const Icon(Icons.edit, size: 20),
        label: const Text(
          'Edit Profile',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildEditProfileSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter first name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter username';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter email';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isEditFormVisible = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textSecondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSavingProfile ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isSavingProfile
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
