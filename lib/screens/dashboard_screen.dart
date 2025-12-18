import 'package:event_planner/screens/buttom_screen/profile_screen.dart';
import 'package:event_planner/screens/buttom_screen/search_screen.dart';
import 'package:event_planner/screens/buttom_screen/home_screen.dart';
import 'package:event_planner/screens/buttom_screen/notification_screen.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final Color background = const Color(0xFFF8DCDC);
  final Color accent = const Color(0xFF800020);

  List<Widget> lstBottomScreen = [
    const HomeScreen(),
    const SearchScreen(),
    const NotificationScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      body: lstBottomScreen[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: accent,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: accent,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white.withOpacity(0.6),
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded, size: 30),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_rounded, size: 30),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_rounded, size: 30),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded, size: 30),
                label: '',
              ),
            ],
            showSelectedLabels: false,
            showUnselectedLabels: false,
            elevation: 0,
          ),
        ),
      ),
    );
  }
}
