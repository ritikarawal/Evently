import 'package:event_planner/widget/common_widget.dart';
import 'package:flutter/material.dart';
import '../../../dashboard/presentation/pages/dashboard_screen.dart';
import 'signup_screen.dart';
import '../../../forgotpassword/presentation/pages/forgotpassword_screen.dart';
import '../../../../common/mysnackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool showPassword = false;

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    AuthTextField(
                      label: "Username",
                      controller: _usernameController,
                      validator: (v) => v!.isEmpty ? "Enter username" : null,
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
                      title: "Log in",
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          showMySnackBar(
                            context: context,
                            message: "Login Successful!",
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DashboardScreen(),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
