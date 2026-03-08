import 'package:event_planner/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:event_planner/features/notifications/domain/usecases/get_unread_count_usecase.dart';
import 'package:event_planner/features/notifications/domain/repositories/notification_repository.dart';
import 'package:event_planner/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:event_planner/features/notifications/domain/entities/notification_entity.dart';
import 'package:event_planner/features/notifications/presentation/state/notification_state.dart';
import 'package:flutter_riverpod/legacy.dart';

class NotificationViewModel extends StateNotifier<NotificationState> {
  final GetNotificationsUsecase _getNotifications;
  final GetUnreadCountUsecase _getUnreadCount;
  final NotificationRepository _notificationRepository;

  NotificationViewModel(
    this._getNotifications,
    this._getUnreadCount,
    this._notificationRepository,
  ) : super(const NotificationState());

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final notificationsResult = await _getNotifications();
    final unreadResult = await _getUnreadCount();

    notificationsResult.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (notifications) {
        unreadResult.fold(
          (failure) => state = state.copyWith(
            isLoading: false,
            notifications: notifications,
            errorMessage: failure.message,
          ),
          (unread) => state = state.copyWith(
            isLoading: false,
            notifications: notifications,
            unreadCount: unread,
            errorMessage: null,
          ),
        );
      },
    );
  }

  Future<void> markAsRead(String notificationId) async {
    final result = await _notificationRepository.markAsRead(notificationId);
    result.fold((_) {}, (_) {
      final updated = state.notifications
          .map(
            (n) => n.id == notificationId
                ? NotificationEntity(
                    id: n.id,
                    title: n.title,
                    message: n.message,
                    type: n.type,
                    isRead: true,
                    createdAt: n.createdAt,
                  )
                : n,
          )
          .toList();

      final unread = updated.where((n) => !n.isRead).length;
      state = state.copyWith(notifications: updated, unreadCount: unread);
    });
  }

  Future<void> markAllAsRead() async {
    final result = await _notificationRepository.markAllAsRead();
    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (_) {
        final updated = state.notifications
            .map(
              (n) => NotificationEntity(
                id: n.id,
                title: n.title,
                message: n.message,
                type: n.type,
                isRead: true,
                createdAt: n.createdAt,
              ),
            )
            .toList();
        state = state.copyWith(
          notifications: updated,
          unreadCount: 0,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> deleteNotification(String notificationId) async {
    final result = await _notificationRepository.deleteNotification(
      notificationId,
    );

    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (_) {
        final updated = state.notifications
            .where((n) => n.id != notificationId)
            .toList();
        final unread = updated.where((n) => !n.isRead).length;
        state = state.copyWith(
          notifications: updated,
          unreadCount: unread,
          errorMessage: null,
        );
      },
    );
  }
}

final notificationViewModelProvider =
    StateNotifierProvider<NotificationViewModel, NotificationState>((ref) {
      final getNotifications = ref.read(getNotificationsUsecaseProvider);
      final getUnread = ref.read(getUnreadCountUsecaseProvider);
      final notificationRepository = ref.read(notificationRepositoryProvider);
      return NotificationViewModel(
        getNotifications,
        getUnread,
        notificationRepository,
      );
    });
