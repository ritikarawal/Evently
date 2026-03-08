import 'package:event_planner/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:event_planner/features/auth/presentation/state/auth_state.dart';
import 'package:event_planner/features/admin/presentation/pages/admin_dashboard_screen.dart';
import 'package:event_planner/widget/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../dashboard/presentation/pages/dashboard_screen.dart';
import 'signup_screen.dart';
import '../../../forgotpassword/presentation/pages/forgotpassword_screen.dart';
import '../../../../common/mysnackbar.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const String _adminEmail = 'ri@gmail.com';

  final _formKey = GlobalKey<FormState>();
  bool showPassword = false;
  bool _isSubmitting = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final authViewModel = ref.read(authViewModelProvider.notifier);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (!mounted) return;

      if (next.status == AuthStatus.loading) return;
      _isSubmitting = false;

      if (previous?.status != AuthStatus.authenticated &&
          next.status == AuthStatus.authenticated) {
        showMySnackBar(context: context, message: "Login Successful!");
        final isAdmin = next.user?.email.trim().toLowerCase() == _adminEmail;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => isAdmin
                ? const AdminDashboardScreen()
                : const DashboardScreen(),
          ),
        );
      } else if (previous?.status != AuthStatus.error &&
          next.status == AuthStatus.error) {
        showMySnackBar(
          context: context,
          message: next.errorMessage ?? 'Login failed',
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
              isLogin: true,
              onLoginTap: () {},
              onSignupTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AuthTextField(
                        label: "Email",
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v!.isEmpty) return "Enter email";
                          if (!v.contains('@')) return "Enter valid email";
                          return null;
                        },
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
                        validator: (v) => v!.isEmpty ? "Enter password" : null,
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ForgotpasswordScreen(),
                              ),
                            );
                          },
                          child: const Text("Forgot password?"),
                        ),
                      ),

                      const SizedBox(height: 20),

                      PrimaryButton(
                        title: authState.status == AuthStatus.loading
                            ? "Logging in..."
                            : "Log in",
                        onPressed: () {
                          if (_isSubmitting ||
                              authState.status == AuthStatus.loading) {
                            return;
                          }
                          if (_formKey.currentState!.validate()) {
                            _isSubmitting = true;
                            authViewModel.login(
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignupScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Sign up",
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
