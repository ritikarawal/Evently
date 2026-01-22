import 'package:event_planner/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:event_planner/features/auth/presentation/state/auth_state.dart';
import 'package:event_planner/features/auth/domain/entities/auth_entity.dart';
import 'package:event_planner/widget/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/mysnackbar.dart';
import 'login_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  bool showPassword = false;
  bool showConfirmPassword = false;

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes
    final authState = ref.watch(authViewModelProvider);
    final authViewModel = ref.read(authViewModelProvider.notifier);

    // Handle signup state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authState.status == AuthStatus.registered) {
        showMySnackBar(
          context: context,
          message: "Account Created Successfully! Please log in.",
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else if (authState.status == AuthStatus.error) {
        showMySnackBar(
          context: context,
          message: authState.errorMessage ?? 'Signup failed',
          color: Colors.red,
        );
        authViewModel.clearError();
      }
    });

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 80),

          Image.asset("assets/images/eventlylogo.png", height: 100),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AuthToggle(
              isLogin: false,
              onLoginTap: () => Navigator.pop(context),
              onSignupTap: () {},
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: AuthScreenWrapper(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AuthTextField(
                        label: "Full Name",
                        controller: _fullNameController,
                        validator: (v) {
                          if (v!.isEmpty) return "Enter full name";
                          final names = v.trim().split(' ');
                          if (names.length < 2) {
                            return "Please enter both first and last name";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      AuthTextField(
                        label: "Email",
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v!.isEmpty) return "Enter email";
                          if (!v.contains('@')) return "Invalid email";
                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      AuthTextField(
                        label: "Username",
                        controller: _usernameController,
                        validator: (v) => v!.isEmpty ? "Enter username" : null,
                      ),

                      const SizedBox(height: 15),

                      AuthTextField(
                        label: "Phone Number",
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (v) =>
                            v!.isEmpty ? "Enter phone number" : null,
                      ),

                      const SizedBox(height: 15),

                      AuthTextField(
                        label: "Password",
                        controller: _passwordController,
                        obscureText: !showPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            showPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              showPassword = !showPassword;
                            });
                          },
                        ),
                        validator: (v) {
                          if (v!.isEmpty) return "Enter password";
                          if (v.length < 6) return "Min 6 characters";
                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      AuthTextField(
                        label: "Confirm Password",
                        controller: _confirmPasswordController,
                        obscureText: !showConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            showConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              showConfirmPassword = !showConfirmPassword;
                            });
                          },
                        ),
                        validator: (v) {
                          if (v != _passwordController.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 25),

                      PrimaryButton(
                        title: authState.status == AuthStatus.loading
                            ? "Creating Account..."
                            : "Sign Up",
                        onPressed: () {
                          if (authState.status != AuthStatus.loading &&
                              _formKey.currentState!.validate()) {
                            // Prepare auth entity and also ensure backend-required fields
                            final fullName = _fullNameController.text.trim();
                            final names = fullName.split(' ');
                            final firstName = names.isNotEmpty
                                ? names.first
                                : '';
                            final lastName = names.length > 1
                                ? names.sublist(1).join(' ')
                                : '';

                            final newUser = AuthEntity(
                              fullName: fullName,
                              email: _emailController.text.trim(),
                              username: _usernameController.text.trim(),
                              phoneNumber: _phoneController.text.trim(),
                              password: _passwordController.text,
                            );

                            // Register with confirm password
                            authViewModel.register(
                              newUser,
                              _confirmPasswordController.text,
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account? "),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              "Log in",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
