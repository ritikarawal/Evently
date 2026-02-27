import 'package:flutter/material.dart';
import 'package:event_planner/theme/app_colors.dart';

class EventDiscoveryScreen extends StatefulWidget {
  const EventDiscoveryScreen({super.key});

  @override
  State<EventDiscoveryScreen> createState() => _EventDiscoveryScreenState();
}

class _EventDiscoveryScreenState extends State<EventDiscoveryScreen> {
  late TextEditingController _searchController;
  String _selectedCategory = 'All';
  String _selectedSort = 'Trending';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Discover Events'),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: CustomScrollView(
        slivers: [
          // Search Bar
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            flexibleSpace: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildSearchBar(),
            ),
          ),

          // Filter Chips
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            flexibleSpace: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildFilterChips(),
            ),
          ),

          // Event Grid
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                return _EventCard(
                  title: 'Event ${index + 1}',
                  category: 'Birthday',
                  date: 'Mar ${15 + index}, 2026',
                  attendees: 24 + (index * 5),
                  imageUrl: 'https://via.placeholder.com/300x200',
                );
              }, childCount: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search events...',
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
              )
            : null,
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      onChanged: (_) {
        setState(() {});
      },
    );
  }

  Widget _buildFilterChips() {
    final categories = ['All', 'Birthday', 'Wedding', 'Conference', 'Workshop'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...categories.map((category) {
            final isSelected = _selectedCategory == category;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedCategory = category);
                },
                backgroundColor: AppColors.cardBackground,
                selectedColor: AppColors.primary.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final String title;
  final String category;
  final String date;
  final int attendees;
  final String imageUrl;

  const _EventCard({
    required this.title,
    required this.category,
    required this.date,
    required this.attendees,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to event details
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.image,
                  size: 40,
                  color: AppColors.primary.withOpacity(0.5),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          date,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$attendees attending',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
