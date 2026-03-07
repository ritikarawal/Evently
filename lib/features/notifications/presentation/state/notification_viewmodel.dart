import 'package:event_planner/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:event_planner/features/notifications/domain/usecases/get_unread_count_usecase.dart';
import 'package:event_planner/features/notifications/presentation/state/notification_state.dart';
import 'package:flutter_riverpod/legacy.dart';

class NotificationViewModel extends StateNotifier<NotificationState> {
  final GetNotificationsUsecase _getNotifications;
  final GetUnreadCountUsecase _getUnreadCount;

  NotificationViewModel(this._getNotifications, this._getUnreadCount)
    : super(const NotificationState());

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
}

final notificationViewModelProvider =
    StateNotifierProvider<NotificationViewModel, NotificationState>((ref) {
      final getNotifications = ref.read(getNotificationsUsecaseProvider);
      final getUnread = ref.read(getUnreadCountUsecaseProvider);
      return NotificationViewModel(getNotifications, getUnread);
    });
