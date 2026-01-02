import 'dart:async';

import 'package:event_planner/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:event_planner/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:event_planner/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    // Wait for auth state to be checked
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Get current auth state
    final authState = ref.read(authViewModelProvider);

    // Navigate based on session status
    if (authState.status.toString().contains('authenticated')) {
      // User is logged in, go to dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      // User is not logged in, go to onboarding
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen1()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Image.asset(
                  "assets/images/eventlylogo.png",
                  height: 300,
                  width: 200,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "Your event planning assistant.",
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
