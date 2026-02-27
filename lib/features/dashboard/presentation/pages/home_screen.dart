import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:event_planner/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:event_planner/features/event/domain/entities/event.dart';
import 'package:event_planner/features/event/presentation/pages/event_details_screen.dart';
import 'package:event_planner/theme/app_colors.dart';
import 'package:event_planner/features/event/presentation/pages/quick_create_event_screen.dart';
import 'package:event_planner/features/event/presentation/pages/create_event_form_screen.dart';
import 'package:event_planner/features/event/presentation/state/event_viewmodel.dart';

final dashboardEventsProvider = FutureProvider<List<Event>>((ref) async {
  final authState = ref.read(authViewModelProvider);
  final organizerId = authState.user?.authId;

  final repository = ref.read(eventRepositoryProvider);
  return repository
      .getUserEvents(organizerId ?? '')
      .timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw Exception(
          'Request timeout. Check backend connection and try again.',
        ),
      );
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<_CategoryStory> _categories = [
    _CategoryStory(
      icon: Icons.cake,
      label: 'Birthday',
      color: Colors.red.shade300,
      key: 'birthday',
    ),
    _CategoryStory(
      icon: Icons.favorite,
      label: 'Anniversary',
      color: Colors.red.shade400,
      key: 'anniversary',
    ),
    _CategoryStory(
      icon: Icons.people,
      label: 'Wedding',
      color: Colors.blue.shade300,
      key: 'wedding',
    ),
    _CategoryStory(
      icon: Icons.favorite_border,
      label: 'Engagement',
      color: Colors.red.shade600,
      key: 'engagement',
    ),
    _CategoryStory(
      icon: Icons.business_center,
      label: 'Workshop',
      color: Colors.purple.shade400,
      key: 'workshop',
    ),
    _CategoryStory(
      icon: Icons.groups,
      label: 'Conference',
      color: Colors.green.shade500,
      key: 'conference',
    ),
    _CategoryStory(
      icon: Icons.school,
      label: 'Graduation',
      color: Colors.orange.shade400,
      key: 'graduation',
    ),
    _CategoryStory(
      icon: Icons.card_giftcard,
      label: 'Fundraiser',
      color: Colors.teal.shade500,
      key: 'fundraisers',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(dashboardEventsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Discover & Create',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    'Quick Start',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(
                  height: 112,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      return GestureDetector(
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
                        child: Container(
                          width: 80,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      category.color,
                                      category.color.withOpacity(0.6),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: category.color.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Container(
                                  margin: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: Icon(
                                    category.icon,
                                    color: AppColors.primary,
                                    size: 30,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                category.label,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyTabBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                tabs: const [
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Past Events'),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            child: eventsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.primary.withOpacity(0.35),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Could not load events',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: const TextStyle(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () =>
                            ref.invalidate(dashboardEventsProvider),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (events) {
                final grouped = _splitEvents(events);
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildEventList(grouped.upcoming, true),
                    _buildEventList(grouped.past, false),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const QuickCreateEventScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Create Event',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  _SplitEvents _splitEvents(List<Event> events) {
    final now = DateTime.now();
    final upcoming = <Event>[];
    final past = <Event>[];

    for (final event in events) {
      final date = event.startDate;
      if (date == null || !date.isBefore(now)) {
        upcoming.add(event);
      } else {
        past.add(event);
      }
    }

    upcoming.sort((a, b) {
      final aDate = a.startDate;
      final bDate = b.startDate;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return aDate.compareTo(bDate);
    });

    past.sort((a, b) {
      final aDate = a.startDate;
      final bDate = b.startDate;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });

    return _SplitEvents(upcoming: upcoming, past: past);
  }

  Widget _buildEventList(List<Event> events, bool isUpcoming) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUpcoming ? Icons.event_available : Icons.history,
              size: 64,
              color: AppColors.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              isUpcoming ? 'No upcoming events' : 'No past events',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first event to get started',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EventDetailsScreen(
                      eventTitle: event.title.isEmpty
                          ? 'Untitled Event'
                          : event.title,
                      category: event.category.isEmpty
                          ? 'General'
                          : event.category,
                      date: _formatEventDate(event.startDate),
                      time: _formatEventTime(event.startDate),
                      location: event.location.isEmpty
                          ? 'Location not set'
                          : event.location,
                      attendees: event.attendeeIds.length,
                      description: event.description,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Stack(
                  children: [
                    Positioned(
                      right: 8,
                      top: 4,
                      child: Icon(
                        Icons.mail_outline,
                        size: 18,
                        color: AppColors.primary.withOpacity(0.35),
                      ),
                    ),
                    Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _categoryIcon(event.category),
                                color: AppColors.primary,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.title.isEmpty
                                        ? 'Untitled Event'
                                        : event.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatEventDate(event.startDate),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          event.location.isEmpty
                                              ? 'Location not set'
                                              : event.location,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textSecondary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 1,
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatEventTime(event.startDate),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.people,
                                    size: 14,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${event.attendeeIds.length}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
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
                                event.category.isEmpty
                                    ? 'General'
                                    : event.category,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatEventDate(DateTime? dateTime) {
    if (dateTime == null) return 'Date TBA';
    return DateFormat('MMM d, yyyy').format(dateTime);
  }

  String _formatEventTime(DateTime? dateTime) {
    if (dateTime == null) return 'Time TBA';
    return DateFormat('h:mm a').format(dateTime);
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'birthday':
        return Icons.cake;
      case 'anniversary':
      case 'engagement':
        return Icons.favorite;
      case 'wedding':
        return Icons.people;
      case 'workshop':
        return Icons.business_center;
      case 'conference':
        return Icons.groups;
      case 'graduation':
        return Icons.school;
      case 'fundraiser':
      case 'fundraisers':
        return Icons.card_giftcard;
      default:
        return Icons.event;
    }
  }
}

class _CategoryStory {
  final IconData icon;
  final String label;
  final Color color;
  final String key;

  const _CategoryStory({
    required this.icon,
    required this.label,
    required this.color,
    required this.key,
  });
}

class _SplitEvents {
  final List<Event> upcoming;
  final List<Event> past;

  const _SplitEvents({required this.upcoming, required this.past});
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  const _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: AppColors.background, child: tabBar);
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return false;
  }
}
