import 'dart:async';

import 'package:event_planner/features/dashboard/presentation/pages/home_screen.dart';
import 'package:event_planner/features/dashboard/presentation/pages/event_screen.dart';
import 'package:event_planner/features/dashboard/presentation/pages/notification_screen.dart';
import 'package:event_planner/features/dashboard/presentation/pages/profile_screen.dart';
import 'package:event_planner/features/event/presentation/pages/create_event_form_screen.dart';
import 'package:event_planner/features/chat/presentation/pages/user_admin_chat_screen.dart';
import 'package:event_planner/features/chat/presentation/state/chat_viewmodel.dart';
import 'package:event_planner/features/notifications/presentation/state/notification_viewmodel.dart';
import 'package:event_planner/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with WidgetsBindingObserver {
  int _selectedIndex = 0;
  Timer? _badgeRefreshTimer;

  final List<Widget> lstBottomScreen = const [
    HomeScreen(),
    EventScreen(),
    NotificationScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() {
      ref.read(notificationViewModelProvider.notifier).loadNotifications();
      ref.read(chatViewModelProvider.notifier).loadUnreadCount();
    });

    _badgeRefreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;
      ref.read(notificationViewModelProvider.notifier).loadNotifications();
      ref.read(chatViewModelProvider.notifier).loadUnreadCount();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _badgeRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(notificationViewModelProvider.notifier).loadNotifications();
      ref.read(chatViewModelProvider.notifier).loadUnreadCount();
    }
  }

  Future<void> _openUserAdminChat() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UserAdminChatScreen()),
    );

    if (!mounted) return;
    ref.read(chatViewModelProvider.notifier).loadUnreadCount();
  }

  Widget _buildBadge(int count) {
    final text = count > 99 ? '99+' : '$count';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 1.2),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon({
    required IconData icon,
    required int index,
    int badgeCount = 0,
  }) {
    final isSelected = _selectedIndex == index;

    return IconButton(
      onPressed: () {
        setState(() {
          _selectedIndex = index;
        });

        if (index == 2) {
          ref.read(notificationViewModelProvider.notifier).loadNotifications();
        }
      },
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            icon,
            size: 28,
            color: isSelected
                ? const Color.fromARGB(255, 255, 255, 255)
                : Colors.grey.shade500,
          ),
          if (badgeCount > 0)
            Positioned(right: -6, top: -6, child: _buildBadge(badgeCount)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationViewModelProvider);
    final chatState = ref.watch(chatViewModelProvider);

    final notificationsFromList = notificationState.notifications
        .where((n) => !n.isRead)
        .length;
    final notificationUnreadCount = notificationState.unreadCount > 0
        ? notificationState.unreadCount
        : notificationsFromList;

    final messageUnreadCount = chatState.unreadCount;

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
                  _buildNavIcon(
                    icon: Icons.notifications_rounded,
                    index: 2,
                    badgeCount: notificationUnreadCount,
                  ),
                  _buildNavIcon(icon: Icons.person_rounded, index: 3),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 84,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              FloatingActionButton.small(
                heroTag: 'chat_fab',
                backgroundColor: AppColors.primary,
                onPressed: _openUserAdminChat,
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Colors.white,
                ),
              ),
              if (messageUnreadCount > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: _buildBadge(messageUnreadCount),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
