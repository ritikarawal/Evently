import 'package:event_planner/features/dashboard/presentation/pages/home_screen.dart';
import 'package:event_planner/features/dashboard/presentation/pages/event_screen.dart';
import 'package:event_planner/features/dashboard/presentation/pages/notification_screen.dart';
import 'package:event_planner/features/dashboard/presentation/pages/profile_screen.dart';
import 'package:event_planner/features/event/presentation/pages/create_event_form_screen.dart';
import 'package:event_planner/features/chat/presentation/pages/user_admin_chat_screen.dart';
import 'package:event_planner/theme/app_colors.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> lstBottomScreen = const [
    HomeScreen(),
    EventScreen(),
    NotificationScreen(),
    ProfileScreen(),
  ];

  Future<void> _openUserAdminChat() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UserAdminChatScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: lstBottomScreen[_selectedIndex],
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: FloatingActionButton(
              backgroundColor: AppColors.primary,
              elevation: 4,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateEventFormScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            color: AppColors.navBackground,
            child: SizedBox(
              height: 72,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavIcon(icon: Icons.home_rounded, index: 0),
                  _buildNavIcon(icon: Icons.event_rounded, index: 1),
                  const SizedBox(width: 44),
                  _buildNavIcon(icon: Icons.notifications_rounded, index: 2),
                  _buildNavIcon(icon: Icons.person_rounded, index: 3),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 84,
          child: FloatingActionButton.small(
            heroTag: 'chat_fab',
            backgroundColor: AppColors.primary,
            onPressed: _openUserAdminChat,
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavIcon({required IconData icon, required int index}) {
    final isSelected = _selectedIndex == index;
    return IconButton(
      onPressed: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      icon: Icon(
        icon,
        size: 28,
        color: isSelected
            ? const Color.fromARGB(255, 255, 255, 255)
            : Colors.grey.shade500,
      ),
    );
  }
}
