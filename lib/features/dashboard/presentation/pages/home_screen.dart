import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:event_planner/core/localization/app_localizations.dart';
import 'package:event_planner/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:event_planner/features/event/domain/entities/event.dart';
import 'package:event_planner/features/event/presentation/pages/event_details_screen.dart';
import 'package:event_planner/theme/app_colors.dart';
import 'package:event_planner/features/event/presentation/pages/create_event_form_screen.dart';
import 'package:event_planner/features/event/domain/usecases/get_all_events_usecase.dart';

final dashboardEventsProvider = FutureProvider<List<Event>>((ref) async {
  // Keep auth state watched so this provider refreshes when login session changes.
  ref.watch(authViewModelProvider);
  final getAllEvents = ref.read(getAllEventsUsecaseProvider);

  final events = await getAllEvents().timeout(
    const Duration(seconds: 20),
    onTimeout: () => throw Exception(
      'Request timeout. Check backend connection and try again.',
    ),
  );
  return events;
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
    final l10n = context.l10n;
    final eventsAsync = ref.watch(dashboardEventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${l10n.tr('discover')} & ${l10n.tr('search')}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
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

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.80,
      ),
      itemBuilder: (context, index) {
        final event = events[index];
        return _EnvelopeEventCard(
          title: event.title.isEmpty ? 'Untitled Event' : event.title,
          category: _displayCategory(event.category),
          date: _formatEventDate(event.startDate),
          time: _formatEventTime(event.startDate),
          location: event.location.isEmpty
              ? 'Location not set'
              : event.location,
          attendees: event.attendeeIds.length,
          description: event.description,
          icon: _categoryIcon(event.category),
          accentColor: _categoryColor(event.category),
          onViewDetails: () {
            if (event.id.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'This event is missing an ID. Please refresh and try again.',
                  ),
                ),
              );
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    EventDetailsScreen(eventId: event.id, initialEvent: event),
              ),
            );
          },
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

  String _displayCategory(String category) {
    final normalized = category.trim().toLowerCase();
    if (normalized.isEmpty) return 'General';
    if (normalized == 'other') return 'Graduation';
    return category;
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
      case 'other':
        return Icons.school;
      case 'fundraiser':
      case 'fundraisers':
        return Icons.card_giftcard;
      default:
        return Icons.event;
    }
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'birthday':
        return Colors.pink.shade300;
      case 'anniversary':
      case 'engagement':
        return Colors.red.shade300;
      case 'wedding':
        return Colors.blue.shade300;
      case 'workshop':
        return Colors.teal.shade300;
      case 'conference':
        return Colors.orange.shade300;
      case 'graduation':
      case 'other':
        return Colors.deepPurple.shade300;
      case 'fundraiser':
      case 'fundraisers':
        return Colors.green.shade300;
      default:
        return AppColors.primary.withOpacity(0.7);
    }
  }
}

class _EnvelopeEventCard extends StatefulWidget {
  final String title;
  final String category;
  final String date;
  final String time;
  final String location;
  final int attendees;
  final String description;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onViewDetails;

  const _EnvelopeEventCard({
    required this.title,
    required this.category,
    required this.date,
    required this.time,
    required this.location,
    required this.attendees,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.onViewDetails,
  });

  @override
  State<_EnvelopeEventCard> createState() => _EnvelopeEventCardState();
}

class _EnvelopeEventCardState extends State<_EnvelopeEventCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _flapAnimation;
  late final Animation<double> _detailsOpacity;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _flapAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _detailsOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 1, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleCardTap() {
    widget.onViewDetails();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleCardTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubic,
        height: 230,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: widget.accentColor.withOpacity(0.35)),
          boxShadow: [
            BoxShadow(
              color: widget.accentColor.withOpacity(0.18),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 16,
              left: 10,
              right: 10,
              child: FadeTransition(
                opacity: _detailsOpacity,
                child: Transform.translate(
                  offset: Offset(0, (1 - _detailsOpacity.value) * 14),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: widget.accentColor.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 11,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.date,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 11,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.location,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: widget.accentColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.people,
                                    size: 11,
                                    color: widget.accentColor,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${widget.attendees}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: widget.accentColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: widget.onViewDetails,
                              style: TextButton.styleFrom(
                                foregroundColor: widget.accentColor,
                                minimumSize: const Size(0, 28),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Open',
                                style: TextStyle(fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              top: 62,
              child: ClipPath(
                clipper: _EnvelopePocketClipper(),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.accentColor.withOpacity(0.25),
                        widget.accentColor.withOpacity(0.12),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 38, 12, 10),
                    child: Row(
                      children: [
                        Icon(widget.icon, size: 16, color: widget.accentColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: widget.accentColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          _isOpen
                              ? 'Tap to view • hold to close'
                              : 'Tap to open',
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: AnimatedBuilder(
                animation: _flapAnimation,
                builder: (context, child) {
                  final tilt = _flapAnimation.value * 3.05;
                  return Transform(
                    alignment: Alignment.topCenter,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.002)
                      ..rotateX(tilt),
                    child: child,
                  );
                },
                child: ClipPath(
                  clipper: _EnvelopeFlapClipper(),
                  child: Container(
                    height: 78,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.accentColor,
                          widget.accentColor.withOpacity(0.85),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnvelopeFlapClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width * 0.5, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _EnvelopePocketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, size.height * 0.24)
      ..lineTo(size.width * 0.5, 0)
      ..lineTo(size.width, size.height * 0.24)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
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
