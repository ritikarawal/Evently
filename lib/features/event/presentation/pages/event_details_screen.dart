import 'package:event_planner/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:event_planner/features/event/data/repositories/event_repository_impl.dart';
import 'package:event_planner/features/event/domain/entities/event.dart';
import 'package:event_planner/features/payments/data/datasources/payment_status_local_datasource.dart';
import 'package:event_planner/features/payments/presentation/pages/event_payment_screen.dart';
import 'package:event_planner/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class EventDetailsScreen extends ConsumerStatefulWidget {
  const EventDetailsScreen({
    super.key,
    required this.eventId,
    this.initialEvent,
  });

  final String eventId;
  final Event? initialEvent;

  @override
  ConsumerState<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends ConsumerState<EventDetailsScreen> {
  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _error;
  Event? _event;
  EventPaymentStatus _paymentStatus = EventPaymentStatus.unpaid;

  @override
  void initState() {
    super.initState();
    _event = widget.initialEvent;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshEvent();
      _refreshPaymentStatus();
    });
  }

  Future<void> _refreshEvent() async {
    if (widget.eventId.isEmpty) {
      setState(() {
        _error = 'Invalid event id.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repository = ref.read(eventRepositoryProvider);
      final event = await repository.getEventById(widget.eventId);
      if (!mounted) return;
      setState(() {
        _event = event;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshPaymentStatus() async {
    final userId = _currentUserId;
    if (userId.isEmpty || widget.eventId.isEmpty) return;

    final store = ref.read(paymentStatusLocalDataSourceProvider);
    final status = store.getStatus(eventId: widget.eventId, userId: userId);
    if (!mounted) return;
    setState(() {
      _paymentStatus = status;
    });
  }

  String get _currentUserId {
    final authState = ref.read(authViewModelProvider);
    return authState.user?.authId ?? '';
  }

  bool get _isLoggedIn => _currentUserId.isNotEmpty;

  bool get _isOrganizer {
    final event = _event;
    if (event == null) return false;
    return event.organizerId == _currentUserId;
  }

  bool get _isJoined {
    final event = _event;
    if (event == null) return false;
    return event.attendeeIds.contains(_currentUserId);
  }

  bool get _isPaidEvent {
    final event = _event;
    if (event == null) return false;
    return event.eventType == 'paid' || event.ticketPrice > 0;
  }

  bool get _isFull {
    final event = _event;
    if (event == null) return false;
    if (event.capacity <= 0) return false;
    return event.attendeeIds.length >= event.capacity;
  }

  Future<void> _handleJoinOrLeave() async {
    final event = _event;
    if (event == null || _isActionLoading) return;

    if (!_isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to join this event.')),
      );
      return;
    }

    if (_isOrganizer) return;

    setState(() {
      _isActionLoading = true;
    });

    try {
      final repository = ref.read(eventRepositoryProvider);
      Event updated;
      if (_isJoined) {
        updated = await repository.leaveEvent(event.id);
        if (_isPaidEvent) {
          final store = ref.read(paymentStatusLocalDataSourceProvider);
          await store.clearStatus(eventId: event.id, userId: _currentUserId);
          _paymentStatus = EventPaymentStatus.unpaid;
        }
      } else {
        if (_isFull) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Event is full.')));
          return;
        }
        updated = await repository.joinEvent(event.id);
        if (_isPaidEvent) {
          final store = ref.read(paymentStatusLocalDataSourceProvider);
          await store.setStatus(
            eventId: event.id,
            userId: _currentUserId,
            status: EventPaymentStatus.unpaid,
          );
          _paymentStatus = EventPaymentStatus.unpaid;
        }
      }

      if (!mounted) return;
      setState(() {
        _event = updated;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Action failed: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isActionLoading = false;
        });
      }
    }
  }

  Future<void> _goToPayment() async {
    final event = _event;
    if (event == null || !_isLoggedIn || !_isPaidEvent) return;

    final amount = event.ticketPrice.round();
    final paid = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EventPaymentScreen(
          eventId: event.id,
          userId: _currentUserId,
          eventTitle: event.title,
          amount: amount,
        ),
      ),
    );

    if (paid == true) {
      await _refreshPaymentStatus();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Payment verified.')));
    }
  }

  String _formatDate(DateTime? value) {
    if (value == null) return 'TBA';
    return DateFormat('MMM d, yyyy').format(value);
  }

  String _formatTime(DateTime? value) {
    if (value == null) return 'TBA';
    return DateFormat('h:mm a').format(value);
  }

  @override
  Widget build(BuildContext context) {
    final event = _event;

    if (_isLoading && event == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null && event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event Details')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 56),
                const SizedBox(height: 10),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _refreshEvent,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (event == null) {
      return const Scaffold(body: Center(child: Text('Event not found.')));
    }

    final primaryButtonLabel = _isOrganizer
        ? 'Organizer'
        : !_isLoggedIn
        ? 'Login to Join'
        : _isJoined
        ? 'Leave Event'
        : _isFull
        ? 'Event Full'
        : 'Join Event';

    final isPrimaryDisabled =
        _isActionLoading || _isOrganizer || (!_isJoined && _isFull);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          IconButton(onPressed: _refreshEvent, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title.isEmpty ? 'Untitled Event' : event.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _pill(
                  icon: Icons.category,
                  text: event.category.isEmpty ? 'General' : event.category,
                ),
                _pill(icon: Icons.event_available, text: event.status),
                _pill(
                  icon: Icons.people,
                  text: event.capacity > 0
                      ? '${event.attendeeIds.length}/${event.capacity}'
                      : '${event.attendeeIds.length} attendees',
                ),
                _pill(
                  icon: _isPaidEvent ? Icons.payments : Icons.money_off,
                  text: _isPaidEvent
                      ? 'Paid (NPR ${event.ticketPrice.round()})'
                      : 'Free',
                ),
              ],
            ),
            const SizedBox(height: 20),
            _infoCard(
              icon: Icons.calendar_month,
              title: 'Date',
              value: _formatDate(event.startDate),
            ),
            const SizedBox(height: 10),
            _infoCard(
              icon: Icons.access_time,
              title: 'Time',
              value: _formatTime(event.startDate),
            ),
            const SizedBox(height: 10),
            _infoCard(
              icon: Icons.event,
              title: 'Ends On',
              value: _formatDate(event.endDate),
            ),
            const SizedBox(height: 10),
            _infoCard(
              icon: Icons.location_on,
              title: 'Location',
              value: event.location.isEmpty
                  ? 'Location not set'
                  : event.location,
            ),
            const SizedBox(height: 10),
            _infoCard(
              icon: _isPaidEvent ? Icons.payments : Icons.money_off,
              title: _isPaidEvent ? 'Paid Amount' : 'Event Type',
              value: _isPaidEvent
                  ? 'NPR ${event.ticketPrice.round()}'
                  : 'Free Event',
            ),
            const SizedBox(height: 18),
            const Text(
              'About Event',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              event.description.isEmpty
                  ? 'Event details will be updated soon.'
                  : event.description,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            if (_isPaidEvent && _isJoined && !_isOrganizer)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _paymentStatus == EventPaymentStatus.paid
                          ? 'Payment Completed'
                          : 'Payment Pending',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _paymentStatus == EventPaymentStatus.paid
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _paymentStatus == EventPaymentStatus.paid
                            ? null
                            : _goToPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          _paymentStatus == EventPaymentStatus.paid
                              ? 'Paid'
                              : 'Proceed to Payment',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isPrimaryDisabled ? null : _handleJoinOrLeave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                ),
                child: _isActionLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(primaryButtonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withOpacity(0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
