import 'package:event_planner/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:event_planner/features/event/data/repositories/event_repository_impl.dart';
import 'package:event_planner/features/event/domain/entities/event.dart';
import 'package:event_planner/features/payments/data/datasources/payment_status_local_datasource.dart';
import 'package:event_planner/features/payments/presentation/pages/event_payment_screen.dart';
import 'package:event_planner/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class EventDetailsModal extends ConsumerStatefulWidget {
  final Event event;
  final String categoryIcon;
  final Color accentColor;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;
  final VoidCallback? onEventChanged;

  const EventDetailsModal({
    super.key,
    required this.event,
    required this.categoryIcon,
    required this.accentColor,
    this.onEdit,
    this.onDelete,
    this.onShare,
    this.onEventChanged,
  });

  static void show(
    BuildContext context, {
    required Event event,
    required String categoryIcon,
    required Color accentColor,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
    VoidCallback? onShare,
    VoidCallback? onEventChanged,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => EventDetailsModal(
        event: event,
        categoryIcon: categoryIcon,
        accentColor: accentColor,
        onEdit: onEdit,
        onDelete: onDelete,
        onShare: onShare,
        onEventChanged: onEventChanged,
      ),
    );
  }

  @override
  ConsumerState<EventDetailsModal> createState() => _EventDetailsModalState();
}

class _EventDetailsModalState extends ConsumerState<EventDetailsModal> {
  bool _isActionLoading = false;
  bool _paymentStepReady = false;
  Event? _event;
  EventPaymentStatus _paymentStatus = EventPaymentStatus.unpaid;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshPaymentStatus();
    });
  }

  String _formatEventDate(DateTime? dateTime) {
    if (dateTime == null) return 'Date TBA';
    return DateFormat('MMMM d, yyyy').format(dateTime);
  }

  String _formatEventTime(DateTime? dateTime) {
    if (dateTime == null) return 'Time TBA';
    return DateFormat('h:mm a').format(dateTime);
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
    if (event == null || _currentUserId.isEmpty) return false;
    return event.attendeeIds.contains(_currentUserId);
  }

  bool get _isPaidEvent {
    final event = _event;
    if (event == null) return false;
    return event.eventType.toLowerCase() == 'paid' || event.ticketPrice > 0;
  }

  bool get _isFull {
    final event = _event;
    if (event == null || event.capacity <= 0) return false;
    return event.attendeeIds.length >= event.capacity;
  }

  Future<void> _refreshPaymentStatus() async {
    final event = _event;
    if (event == null || _currentUserId.isEmpty || event.id.isEmpty) return;
    final store = ref.read(paymentStatusLocalDataSourceProvider);
    final status = store.getStatus(eventId: event.id, userId: _currentUserId);
    if (!mounted) return;
    setState(() {
      _paymentStatus = status;
    });
  }

  Future<void> _handleJoinOrLeave() async {
    final event = _event;
    if (event == null || _isActionLoading || event.id.isEmpty) return;

    if (!_isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to join this event.')),
      );
      return;
    }

    if (_isOrganizer) {
      return;
    }

    if (_isFull && !_isJoined) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Event is full.')));
      return;
    }

    if (_isPaidEvent && !_isJoined) {
      setState(() {
        _paymentStepReady = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proceed to payment to confirm your booking.'),
        ),
      );
      return;
    }

    setState(() {
      _isActionLoading = true;
    });

    try {
      final repo = ref.read(eventRepositoryProvider);
      final wasJoined = _isJoined;
      Event updated;
      if (wasJoined) {
        updated = await repo.leaveEvent(event.id);
        if (_isPaidEvent) {
          final store = ref.read(paymentStatusLocalDataSourceProvider);
          await store.clearStatus(eventId: event.id, userId: _currentUserId);
          _paymentStatus = EventPaymentStatus.unpaid;
        }
      } else {
        updated = await repo.joinEvent(event.id);
      }

      if (!mounted) return;
      setState(() {
        _event = updated;
        _isActionLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasJoined ? 'Left event successfully' : 'Joined event successfully',
          ),
        ),
      );
      widget.onEventChanged?.call();
    } catch (e) {
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('already attending')) {
        try {
          final repo = ref.read(eventRepositoryProvider);
          final refreshed = await repo.getEventById(event.id);
          if (!mounted) return;
          setState(() {
            _event = refreshed;
            _isActionLoading = false;
          });
          widget.onEventChanged?.call();
          return;
        } catch (_) {
          // Fall through to generic error snackbar below.
        }
      }
      if (!mounted) return;
      setState(() {
        _isActionLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _handleProceedToPayment() async {
    final event = _event;
    if (event == null || event.id.isEmpty) return;

    if (!_isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to join this event.')),
      );
      return;
    }

    if (!_isJoined && !_paymentStepReady) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tap Join Event first.')));
      return;
    }

    if (!mounted) return;

    final paid = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EventPaymentScreen(
          eventId: event.id,
          userId: _currentUserId,
          eventTitle: event.title.isEmpty ? 'Event Payment' : event.title,
          amount: event.ticketPrice <= 0 ? 1 : event.ticketPrice.toInt(),
        ),
      ),
    );

    if (paid == true) {
      await _refreshPaymentStatus();
      try {
        final refreshed = await ref
            .read(eventRepositoryProvider)
            .getEventById(event.id);
        if (mounted) {
          setState(() {
            _event = refreshed;
            _paymentStepReady = false;
          });
        }
      } catch (_) {
        // Keep local state unchanged if refresh fails.
      }
      if (!mounted) return;
      widget.onEventChanged?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment completed successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.9;
    final event = _event;

    if (event == null) {
      return const SizedBox.shrink();
    }

    final isPaid = _paymentStatus == EventPaymentStatus.paid;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title.isEmpty
                                ? 'Untitled Event'
                                : event.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: widget.accentColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: widget.accentColor,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: widget.accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      event.category.isEmpty ? 'General' : event.category,
                      style: TextStyle(
                        color: widget.accentColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _isPaidEvent
                          ? Colors.amber.shade100
                          : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _isPaidEvent
                          ? 'Paid • NPR ${event.ticketPrice.toInt()}'
                          : 'Free Event',
                      style: TextStyle(
                        color: _isPaidEvent
                            ? Colors.amber.shade900
                            : Colors.green.shade900,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildDetailSection(
              icon: Icons.calendar_today,
              title: 'Date & Time',
              value:
                  '${_formatEventDate(event.startDate)}\n${_formatEventTime(event.startDate)}',
              accentColor: widget.accentColor,
            ),
            _buildDetailSection(
              icon: Icons.location_on,
              title: 'Location',
              value: event.location.isEmpty
                  ? 'Location not set'
                  : event.location,
              accentColor: widget.accentColor,
            ),
            if (event.description.isNotEmpty)
              _buildDetailSection(
                icon: Icons.description,
                title: 'Description',
                value: event.description,
                maxLines: null,
                accentColor: widget.accentColor,
              ),
            _buildDetailSection(
              icon: Icons.people,
              title: 'Attendees',
              value: event.capacity > 0
                  ? '${event.attendeeIds.length}/${event.capacity}'
                  : '${event.attendeeIds.length} people attending',
              accentColor: widget.accentColor,
            ),

            if (_isPaidEvent && _isJoined && !_isOrganizer)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isPaid
                          ? Colors.green.shade300
                          : Colors.amber.shade300,
                    ),
                    color: isPaid ? Colors.green.shade50 : Colors.amber.shade50,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isPaid ? Icons.check_circle : Icons.hourglass_top,
                        color: isPaid
                            ? Colors.green.shade700
                            : Colors.amber.shade800,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isPaid ? 'Paid' : 'Unpaid',
                        style: TextStyle(
                          color: isPaid
                              ? Colors.green.shade800
                              : Colors.amber.shade900,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            if (!_isOrganizer)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isActionLoading ? null : _handleJoinOrLeave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isActionLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _isJoined ? 'Leave Event' : 'Join Event',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    if (_isPaidEvent)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: isPaid
                                ? null
                                : (_isJoined || _paymentStepReady)
                                ? _handleProceedToPayment
                                : null,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: widget.accentColor),
                              foregroundColor: widget.accentColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              isPaid ? 'Paid' : 'Proceed to Payment',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            if (_isOrganizer)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    if (widget.onEdit != null)
                      _buildActionButton(
                        label: 'Edit Event',
                        icon: Icons.edit,
                        color: widget.accentColor,
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onEdit?.call();
                        },
                      ),
                    if (widget.onEdit != null &&
                        (widget.onDelete != null || widget.onShare != null))
                      const SizedBox(height: 12),
                    if (widget.onShare != null)
                      _buildActionButton(
                        label: 'Share Event',
                        icon: Icons.share,
                        color: Colors.blue.shade400,
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onShare?.call();
                        },
                      ),
                    if (widget.onShare != null && widget.onDelete != null)
                      const SizedBox(height: 12),
                    if (widget.onDelete != null)
                      _buildActionButton(
                        label: 'Delete Event',
                        icon: Icons.delete_outline,
                        color: Colors.red.shade400,
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onDelete?.call();
                        },
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection({
    required IconData icon,
    required String title,
    required String value,
    required Color accentColor,
    int? maxLines = 2,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.12),
          foregroundColor: color,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
