import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController firstController = TextEditingController();

  final TextEditingController secondController = TextEditingController();
  int result = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
