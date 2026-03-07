import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:event_planner/core/error/failures.dart';
import 'package:event_planner/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:event_planner/features/admin/data/models/admin_user_api_model.dart';
import 'package:event_planner/features/admin/data/models/admin_venue_api_model.dart';
import 'package:event_planner/features/admin/domain/entities/admin_chat_message_entity.dart';
import 'package:event_planner/features/admin/domain/entities/admin_chat_user_entity.dart';
import 'package:event_planner/features/admin/domain/entities/admin_event_entity.dart';
import 'package:event_planner/features/admin/domain/entities/admin_user_entity.dart';
import 'package:event_planner/features/admin/domain/entities/admin_venue_entity.dart';
import 'package:event_planner/features/admin/domain/repositories/admin_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminRepositoryImpl implements AdminRepository {
  final IAdminRemoteDataSource _remote;

  AdminRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<AdminUserEntity>>> getUsers({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final users = await _remote.getUsers(page: page, limit: limit);
      return Right(users.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Failed to fetch users'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdminUserEntity>> createUser({
    required AdminUserEntity user,
    required String password,
  }) async {
    try {
      final created = await _remote.createUser(
        user: AdminUserApiModel(
          id: user.id,
          firstName: user.firstName,
          lastName: user.lastName,
          username: user.username,
          email: user.email,
          phoneNumber: user.phoneNumber,
          role: user.role,
          profilePicture: user.profilePicture,
        ),
        password: password,
      );
      return Right(created.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Failed to create user'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdminUserEntity>> updateUser(
    AdminUserEntity user,
  ) async {
    try {
      final updated = await _remote.updateUser(
        AdminUserApiModel(
          id: user.id,
          firstName: user.firstName,
          lastName: user.lastName,
          username: user.username,
          email: user.email,
          phoneNumber: user.phoneNumber,
          role: user.role,
          profilePicture: user.profilePicture,
        ),
      );
      return Right(updated.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Failed to update user'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteUser(String userId) async {
    try {
      await _remote.deleteUser(userId);
      return const Right(true);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Failed to delete user'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AdminEventEntity>>> getEvents() async {
    try {
      final events = await _remote.getEvents();
      return Right(events.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Left(
        ServerFailure(message: e.message ?? 'Failed to fetch events'),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> approveEvent(
    String eventId, {
    String? adminNotes,
  }) async {
    try {
      await _remote.approveEvent(eventId, adminNotes: adminNotes);
      return const Right(true);
    } on DioException catch (e) {
      return Left(
        ServerFailure(message: e.message ?? 'Failed to approve event'),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> declineEvent(
    String eventId, {
    String? adminNotes,
  }) async {
    try {
      await _remote.declineEvent(eventId, adminNotes: adminNotes);
      return const Right(true);
    } on DioException catch (e) {
      return Left(
        ServerFailure(message: e.message ?? 'Failed to decline event'),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteEvent(String eventId) async {
    try {
      await _remote.deleteEvent(eventId);
      return const Right(true);
    } on DioException catch (e) {
      return Left(
        ServerFailure(message: e.message ?? 'Failed to delete event'),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AdminVenueEntity>>> getVenues() async {
    try {
      final venues = await _remote.getVenues();
      return Right(venues.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Left(
        ServerFailure(message: e.message ?? 'Failed to fetch venues'),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdminVenueEntity>> createVenue(
    AdminVenueEntity venue,
  ) async {
    try {
      final created = await _remote.createVenue(
        AdminVenueApiModel(
          id: venue.id,
          name: venue.name,
          city: venue.city,
          state: venue.state,
          address: venue.address,
          capacity: venue.capacity,
          isActive: venue.isActive,
        ),
      );
      return Right(created.toEntity());
    } on DioException catch (e) {
      return Left(
        ServerFailure(message: e.message ?? 'Failed to create venue'),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AdminChatUserEntity>>> getChatUsers() async {
    try {
      final users = await _remote.getChatUsers();
      return Right(users.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Left(
        ServerFailure(message: e.message ?? 'Failed to fetch chat users'),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AdminChatMessageEntity>>> getUserChat(
    String userId,
  ) async {
    try {
      final messages = await _remote.getUserChat(userId);
      return Right(messages.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Left(
        ServerFailure(message: e.message ?? 'Failed to fetch chat history'),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdminChatMessageEntity>> sendAdminMessage({
    required String userId,
    required String text,
    String? adminName,
  }) async {
    try {
      final message = await _remote.sendAdminMessage(
        userId: userId,
        text: text,
        adminName: adminName,
      );
      return Right(message.toEntity());
    } on DioException catch (e) {
      return Left(
        ServerFailure(message: e.message ?? 'Failed to send message'),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepositoryImpl(ref.read(adminRemoteDataSourceProvider));
});
