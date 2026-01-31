import 'package:flutter/material.dart';
import '../../../../widget/event_categories_grid.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: EventCategoriesGrid(),
      ),
    );
  }
}
