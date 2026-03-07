import 'package:event_planner/features/auth/presentation/pages/login_screen.dart';
import 'package:event_planner/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:event_planner/features/admin/presentation/pages/admin_dashboard_screen.dart';
import 'package:event_planner/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:event_planner/features/splash/presentation/pages/Splash_screen.dart';
import 'package:event_planner/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/presentation/state/auth_state.dart';

class App extends ConsumerWidget {
  const App({super.key});

  static const String _adminEmail = 'ri@gmail.com';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      theme: getApplicationTheme(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/admin': (context) => const AdminDashboardScreen(),
      },
      home: _buildHome(authState),
    );
  }

  Widget _buildHome(AuthState authState) {
    if (authState.status == AuthStatus.authenticated) {
      final email = authState.user?.email.trim().toLowerCase();
      if (email == _adminEmail) {
        return const AdminDashboardScreen();
      }
      return const DashboardScreen();
    }
    return const SplashScreen();
  }
}
