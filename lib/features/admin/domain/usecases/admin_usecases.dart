import 'package:event_planner/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:event_planner/features/admin/domain/entities/admin_user_entity.dart';
import 'package:event_planner/features/admin/domain/entities/admin_venue_entity.dart';
import 'package:event_planner/features/admin/domain/repositories/admin_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetAdminUsersUseCase {
  final AdminRepository repository;
  GetAdminUsersUseCase(this.repository);

  Future call({int page = 1, int limit = 10}) {
    return repository.getUsers(page: page, limit: limit);
  }
}

class CreateAdminUserUseCase {
  final AdminRepository repository;
  CreateAdminUserUseCase(this.repository);

  Future call({required AdminUserEntity user, required String password}) {
    return repository.createUser(user: user, password: password);
  }
}

class UpdateAdminUserUseCase {
  final AdminRepository repository;
  UpdateAdminUserUseCase(this.repository);

  Future call(AdminUserEntity user) {
    return repository.updateUser(user);
  }
}

class DeleteAdminUserUseCase {
  final AdminRepository repository;
  DeleteAdminUserUseCase(this.repository);

  Future call(String userId) {
    return repository.deleteUser(userId);
  }
}

class GetAdminEventsUseCase {
  final AdminRepository repository;
  GetAdminEventsUseCase(this.repository);

  Future call() {
    return repository.getEvents();
  }
}

class ApproveAdminEventUseCase {
  final AdminRepository repository;
  ApproveAdminEventUseCase(this.repository);

  Future call(String eventId, {String? adminNotes}) {
    return repository.approveEvent(eventId, adminNotes: adminNotes);
  }
}

class DeclineAdminEventUseCase {
  final AdminRepository repository;
  DeclineAdminEventUseCase(this.repository);

  Future call(String eventId, {String? adminNotes}) {
    return repository.declineEvent(eventId, adminNotes: adminNotes);
  }
}

class DeleteAdminEventUseCase {
  final AdminRepository repository;
  DeleteAdminEventUseCase(this.repository);

  Future call(String eventId) {
    return repository.deleteEvent(eventId);
  }
}

class GetAdminVenuesUseCase {
  final AdminRepository repository;
  GetAdminVenuesUseCase(this.repository);

  Future call() {
    return repository.getVenues();
  }
}

class CreateAdminVenueUseCase {
  final AdminRepository repository;
  CreateAdminVenueUseCase(this.repository);

  Future call(AdminVenueEntity venue) {
    return repository.createVenue(venue);
  }
}

class GetAdminChatUsersUseCase {
  final AdminRepository repository;
  GetAdminChatUsersUseCase(this.repository);

  Future call() {
    return repository.getChatUsers();
  }
}

class GetAdminUserChatUseCase {
  final AdminRepository repository;
  GetAdminUserChatUseCase(this.repository);

  Future call(String userId) {
    return repository.getUserChat(userId);
  }
}

class SendAdminMessageUseCase {
  final AdminRepository repository;
  SendAdminMessageUseCase(this.repository);

  Future call({
    required String userId,
    required String text,
    String? adminName,
  }) {
    return repository.sendAdminMessage(
      userId: userId,
      text: text,
      adminName: adminName,
    );
  }
}

final getAdminUsersUseCaseProvider = Provider<GetAdminUsersUseCase>((ref) {
  return GetAdminUsersUseCase(ref.read(adminRepositoryProvider));
});

final createAdminUserUseCaseProvider = Provider<CreateAdminUserUseCase>((ref) {
  return CreateAdminUserUseCase(ref.read(adminRepositoryProvider));
});

final updateAdminUserUseCaseProvider = Provider<UpdateAdminUserUseCase>((ref) {
  return UpdateAdminUserUseCase(ref.read(adminRepositoryProvider));
});

final deleteAdminUserUseCaseProvider = Provider<DeleteAdminUserUseCase>((ref) {
  return DeleteAdminUserUseCase(ref.read(adminRepositoryProvider));
});

final getAdminEventsUseCaseProvider = Provider<GetAdminEventsUseCase>((ref) {
  return GetAdminEventsUseCase(ref.read(adminRepositoryProvider));
});

final approveAdminEventUseCaseProvider = Provider<ApproveAdminEventUseCase>((
  ref,
) {
  return ApproveAdminEventUseCase(ref.read(adminRepositoryProvider));
});

final declineAdminEventUseCaseProvider = Provider<DeclineAdminEventUseCase>((
  ref,
) {
  return DeclineAdminEventUseCase(ref.read(adminRepositoryProvider));
});

final deleteAdminEventUseCaseProvider = Provider<DeleteAdminEventUseCase>((
  ref,
) {
  return DeleteAdminEventUseCase(ref.read(adminRepositoryProvider));
});

final getAdminVenuesUseCaseProvider = Provider<GetAdminVenuesUseCase>((ref) {
  return GetAdminVenuesUseCase(ref.read(adminRepositoryProvider));
});

final createAdminVenueUseCaseProvider = Provider<CreateAdminVenueUseCase>((
  ref,
) {
  return CreateAdminVenueUseCase(ref.read(adminRepositoryProvider));
});

final getAdminChatUsersUseCaseProvider = Provider<GetAdminChatUsersUseCase>((
  ref,
) {
  return GetAdminChatUsersUseCase(ref.read(adminRepositoryProvider));
});

final getAdminUserChatUseCaseProvider = Provider<GetAdminUserChatUseCase>((
  ref,
) {
  return GetAdminUserChatUseCase(ref.read(adminRepositoryProvider));
});

final sendAdminMessageUseCaseProvider = Provider<SendAdminMessageUseCase>((
  ref,
) {
  return SendAdminMessageUseCase(ref.read(adminRepositoryProvider));
});
