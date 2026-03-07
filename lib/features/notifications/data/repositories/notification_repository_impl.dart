import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:event_planner/core/api/api_client.dart';
import 'package:event_planner/core/error/failures.dart';
import 'package:event_planner/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:event_planner/features/notifications/domain/entities/notification_entity.dart';
import 'package:event_planner/features/notifications/domain/repositories/notification_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationRemoteDataSourceProvider =
    Provider<INotificationRemoteDataSource>((ref) {
      final dio = ref.read(dioProvider);
      return NotificationRemoteDataSource(dio);
    });

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final remote = ref.read(notificationRemoteDataSourceProvider);
  return NotificationRepositoryImpl(remote);
});

class NotificationRepositoryImpl implements NotificationRepository {
  final INotificationRemoteDataSource _remote;

  NotificationRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, bool>> deleteNotification(
    String notificationId,
  ) async {
    try {
      await _remote.deleteNotification(notificationId);
      return const Right(true);
    } on DioException catch (e) {
      return Left(
        ServerFailure(message: e.message ?? 'Failed to delete notification'),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    int limit = 50,
  }) async {
    try {
      final result = await _remote.getNotifications(limit: limit);
      return Right(result.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Left(
        ServerFailure(message: e.message ?? 'Failed to fetch notifications'),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final count = await _remote.getUnreadCount();
      return Right(count);
    } on DioException catch (e) {
      return Left(
        ServerFailure(message: e.message ?? 'Failed to fetch unread count'),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> markAllAsRead() async {
    try {
      await _remote.markAllAsRead();
      return const Right(true);
    } on DioException catch (e) {
      return Left(
        ServerFailure(message: e.message ?? 'Failed to mark all as read'),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> markAsRead(String notificationId) async {
    try {
      await _remote.markAsRead(notificationId);
      return const Right(true);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          message: e.message ?? 'Failed to mark notification as read',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
