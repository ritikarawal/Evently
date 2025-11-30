import 'package:event_planner/screens/Splash_screen.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/splash',
      routes: {'/splash': (context) => SplashScreen()},
    );
  }
}
