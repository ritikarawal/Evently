import 'package:dartz/dartz.dart';
import 'package:event_planner/core/error/failures.dart';
import 'package:event_planner/features/admin/domain/entities/admin_chat_message_entity.dart';
import 'package:event_planner/features/admin/domain/entities/admin_chat_user_entity.dart';
import 'package:event_planner/features/admin/domain/entities/admin_event_entity.dart';
import 'package:event_planner/features/admin/domain/entities/admin_user_entity.dart';
import 'package:event_planner/features/admin/domain/entities/admin_venue_entity.dart';

abstract class AdminRepository {
  Future<Either<Failure, List<AdminUserEntity>>> getUsers({
    int page = 1,
    int limit = 10,
  });

  Future<Either<Failure, AdminUserEntity>> createUser({
    required AdminUserEntity user,
    required String password,
  });

  Future<Either<Failure, AdminUserEntity>> updateUser(AdminUserEntity user);

  Future<Either<Failure, bool>> deleteUser(String userId);

  Future<Either<Failure, List<AdminEventEntity>>> getEvents();
  Future<Either<Failure, bool>> approveEvent(
    String eventId, {
    String? adminNotes,
  });
  Future<Either<Failure, bool>> declineEvent(
    String eventId, {
    String? adminNotes,
  });
  Future<Either<Failure, bool>> deleteEvent(String eventId);

  Future<Either<Failure, List<AdminVenueEntity>>> getVenues();
  Future<Either<Failure, AdminVenueEntity>> createVenue(AdminVenueEntity venue);

  Future<Either<Failure, List<AdminChatUserEntity>>> getChatUsers();
  Future<Either<Failure, List<AdminChatMessageEntity>>> getUserChat(
    String userId,
  );
  Future<Either<Failure, AdminChatMessageEntity>> sendAdminMessage({
    required String userId,
    required String text,
    String? adminName,
  });
}
