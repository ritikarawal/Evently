import 'package:dartz/dartz.dart';
import 'package:event_planner/core/error/failures.dart';
import 'package:event_planner/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:event_planner/features/auth/domain/entities/auth_entity.dart';
import 'package:event_planner/features/auth/domain/entities/update_profile_params.dart';
import 'package:event_planner/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final updateProfileUsecaseProvider = Provider<UpdateProfileUseCase>(
  (ref) => UpdateProfileUseCase(repository: ref.read(authRepositoryProvider)),
);

class UpdateProfileUseCase {
  final IAuthRepository repository;

  UpdateProfileUseCase({required this.repository});

  Future<Either<Failure, AuthEntity>> call(UpdateProfileParams params) {
    return repository.updateProfile(params);
  }
}
