import 'package:flutter/material.dart';
import 'package:event_planner/core/localization/app_localizations.dart';
import 'package:event_planner/core/localization/locale_provider.dart';
import 'package:event_planner/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_planner/features/notifications/presentation/state/notification_viewmodel.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          ref.read(notificationViewModelProvider.notifier).loadNotifications(),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'event_approved':
        return Icons.check_circle;
      case 'event_declined':
        return Icons.cancel;
      case 'new_venue_category':
        return Icons.location_city;
      default:
        return Icons.notifications;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'event_approved':
        return Colors.green;
      case 'event_declined':
        return Colors.red;
      case 'new_venue_category':
        return Colors.blue;
      default:
        return AppColors.primary;
    }
  }

  String _formatDate(DateTime? value) {
    if (value == null) return 'Just now';
    final now = DateTime.now();
    final diff = now.difference(value);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${value.day}/${value.month}/${value.year}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    ref.watch(localeProvider); // Watch locale to rebuild when language changes
    final state = ref.watch(notificationViewModelProvider);
    final vm = ref.read(notificationViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr('notifications')),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: state.unreadCount > 0 ? vm.markAllAsRead : null,
            child: Text(l10n.tr('mark_all_read')),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: vm.loadNotifications,
        child: Builder(
          builder: (context) {
            if (state.isLoading && state.notifications.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.errorMessage != null && state.notifications.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          state.errorMessage!,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: vm.loadNotifications,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            if (state.notifications.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 140),
                  Center(
                    child: Text(
                      'No notifications yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: state.notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                final accent = _colorForType(notification.type);

                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    if (!notification.isRead && notification.id.isNotEmpty) {
                      vm.markAsRead(notification.id);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: notification.isRead
                          ? AppColors.cardBackground
                          : accent.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: notification.isRead
                            ? Colors.grey.shade200
                            : accent.withOpacity(0.35),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _iconForType(notification.type),
                            color: accent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: notification.isRead
                                      ? FontWeight.w600
                                      : FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notification.message,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _formatDate(notification.createdAt),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Delete notification',
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: notification.id.isEmpty
                              ? null
                              : () async {
                                  final shouldDelete = await showDialog<bool>(
                                    context: context,
                                    builder: (dialogContext) => AlertDialog(
                                      title: const Text('Delete Notification'),
                                      content: const Text(
                                        'Are you sure you want to delete this notification?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(
                                            dialogContext,
                                            false,
                                          ),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(
                                            dialogContext,
                                            true,
                                          ),
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (shouldDelete == true && mounted) {
                                    vm.deleteNotification(notification.id);
                                  }
                                },
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
