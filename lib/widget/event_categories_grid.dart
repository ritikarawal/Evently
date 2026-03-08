import 'package:flutter/material.dart';
import 'package:event_planner/theme/app_colors.dart';
import 'package:event_planner/features/event/presentation/pages/quick_create_event_screen.dart';
import 'package:event_planner/features/event/presentation/pages/create_event_form_screen.dart';

class EventCategoriesGrid extends StatelessWidget {
  const EventCategoriesGrid({super.key});

  // List of event categories
  static final List<_EventCategory> eventCategories = [
    _EventCategory(
      icon: Icons.cake,
      label: 'Birthday',
      color: Colors.red.shade300,
      key: 'birthday',
    ),
    _EventCategory(
      icon: Icons.favorite,
      label: 'Anniversary',
      color: Colors.red.shade400,
      key: 'anniversary',
    ),
    _EventCategory(
      icon: Icons.people,
      label: 'Wedding',
      color: Colors.blue.shade300,
      key: 'wedding',
    ),
    _EventCategory(
      icon: Icons.favorite_border,
      label: 'Engagement',
      color: Colors.red.shade600,
      key: 'engagement',
    ),
    _EventCategory(
      icon: Icons.business_center,
      label: 'Workshop',
      color: Colors.red.shade400,
      key: 'workshop',
    ),
    _EventCategory(
      icon: Icons.groups,
      label: 'Conference',
      color: Colors.red.shade500,
      key: 'conference',
    ),
    _EventCategory(
      icon: Icons.school,
      label: 'Graduation',
      color: Colors.red.shade400,
      key: 'graduation',
    ),
    _EventCategory(
      icon: Icons.card_giftcard,
      label: 'Fundraisers',
      color: Colors.red.shade500,
      key: 'fundraisers',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Start',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select a template to begin creating your event',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
            ),
            itemCount: eventCategories.length,
            itemBuilder: (context, index) {
              final category = eventCategories[index];
              return EventCard(
                icon: category.icon,
                label: category.label,
                color: category.color,
                categoryKey: category.key,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateEventFormScreen(
                        category: category.label,
                        categoryKey: category.key,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EventCategory {
  final IconData icon;
  final String label;
  final Color color;
  final String key;

  const _EventCategory({
    required this.icon,
    required this.label,
    required this.color,
    required this.key,
  });
}

class EventCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String categoryKey;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.categoryKey,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
