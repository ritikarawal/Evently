import 'package:event_planner/features/splash/presentation/pages/Splash_screen.dart';
import 'package:event_planner/theme/app_theme.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/splash',
      theme: getApplicationTheme(),
      routes: {'/splash': (context) => SplashScreen()},
    );
  }
}
