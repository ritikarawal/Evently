import 'package:flutter/material.dart';

class EventCategoriesGrid extends StatelessWidget {
  const EventCategoriesGrid({super.key});

  // List of event categories
  static final List<Map<String, dynamic>> eventCategories = [
    {'icon': Icons.cake, 'label': 'Birthday', 'color': Colors.red.shade300},
    {
      'icon': Icons.favorite,
      'label': 'Anniversary',
      'color': Colors.red.shade400,
    },
    {'icon': Icons.people, 'label': 'Wedding', 'color': Colors.blue.shade300},
    {
      'icon': Icons.favorite_border,
      'label': 'Engagement',
      'color': Colors.red.shade600,
    },
    {
      'icon': Icons.business_center,
      'label': 'Workshop',
      'color': Colors.red.shade400,
    },
    {'icon': Icons.groups, 'label': 'Conference', 'color': Colors.red.shade500},
    {'icon': Icons.school, 'label': 'Graduation', 'color': Colors.red.shade400},
    {
      'icon': Icons.card_giftcard,
      'label': 'Fundraisers',
      'color': Colors.red.shade500,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: eventCategories.length,
      itemBuilder: (context, index) {
        return EventCard(
          icon: eventCategories[index]['icon'],
          label: eventCategories[index]['label'],
          color: eventCategories[index]['color'],
          onTap: () {
            // Handle tap
            print('Tapped on ${eventCategories[index]['label']}');
          },
        );
      },
    );
  }
}

class EventCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
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
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
