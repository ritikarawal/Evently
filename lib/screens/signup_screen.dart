import 'package:event_planner/widget/common_widget.dart';
import 'package:flutter/material.dart';
import '../common/mysnackbar.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  bool showPassword = false;
  bool showConfirmPassword = false;

  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _numberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

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
              isLogin: false,
              onLoginTap: () => Navigator.pop(context),
              onSignupTap: () {},
            ),
          ),

          const SizedBox(height: 20),

          AuthScreenWrapper(
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
                    controller: _numberController,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.isEmpty ? "Enter phone number" : null,
                  ),

                  const SizedBox(height: 15),

                  AuthTextField(
                    label: "Password",
                    controller: _passwordController,
                    obscureText: !showPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        showPassword ? Icons.visibility : Icons.visibility_off,
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
                    title: "Sign Up",
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        showMySnackBar(
                          context: context,
                          message: "Account Created Successfully!",
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
