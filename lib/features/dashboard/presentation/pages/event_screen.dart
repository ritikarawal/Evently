import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:event_planner/theme/app_colors.dart';
import 'package:event_planner/features/event/domain/entities/event.dart';
import 'package:event_planner/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:event_planner/features/event/data/repositories/event_repository_impl.dart';
import 'package:event_planner/features/event/presentation/pages/event_details_screen.dart';

class _EventsTabData {
  final List<Event> myEvents;
  final List<Event> bookedEvents;

  const _EventsTabData({required this.myEvents, required this.bookedEvents});
}

final eventScreenDataProvider = FutureProvider<_EventsTabData>((ref) async {
  final authState = ref.watch(authViewModelProvider);
  final userId = authState.user?.authId ?? '';
  final repository = ref.read(eventRepositoryProvider);

  // Always keep a public list as fallback so cards can still be shown.
  final publicEvents = await repository.getUserEvents('');

  if (userId.isEmpty) {
    return _EventsTabData(myEvents: const [], bookedEvents: publicEvents);
  }

  final userScopeEvents = await repository.getUserEvents(userId);

  final myEvents = userScopeEvents
      .where((event) => event.organizerId == userId)
      .toList();

  final bookedEvents = userScopeEvents
      .where(
        (event) =>
            event.attendeeIds.contains(userId) && event.organizerId != userId,
      )
      .toList();

  // If backend returns no user-scope events, keep the UI populated with
  // public cards instead of showing an empty screen.
  if (myEvents.isEmpty && bookedEvents.isEmpty) {
    return _EventsTabData(myEvents: publicEvents, bookedEvents: publicEvents);
  }

  return _EventsTabData(myEvents: myEvents, bookedEvents: bookedEvents);
});

class EventScreen extends ConsumerStatefulWidget {
  const EventScreen({super.key});

  @override
  ConsumerState<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends ConsumerState<EventScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    final eventsAsync = ref.watch(eventScreenDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Events'),
            Tab(text: 'Booked Events'),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
        ),
      ),
      body: eventsAsync.when(
        data: (eventsData) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildEventGrid(eventsData.myEvents),
              _buildEventGrid(eventsData.bookedEvents),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildEventGrid(List<Event> events) {
    if (events.isEmpty) {
      return const Center(child: Text('No events found'));
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: events.length,
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
                  builder: (_) => EventDetailsScreen(
                    eventId: event.id,
                    initialEvent: event,
                  ),
                ),
              );
            },
          );
        },
      ),
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
