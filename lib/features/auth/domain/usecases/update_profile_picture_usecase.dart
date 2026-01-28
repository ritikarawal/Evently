import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:event_planner/core/error/failures.dart';
import 'package:event_planner/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:event_planner/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/auth_entity.dart';

final updateProfilePictureUsecaseProvider =
    Provider<UpdateProfilePictureUseCase>(
      (ref) => UpdateProfilePictureUseCase(
        repository: ref.read(authRepositoryProvider),
      ),
    );

class UpdateProfilePictureUseCase {
  final IAuthRepository repository;

  UpdateProfilePictureUseCase({required this.repository});

  Future<Either<Failure, AuthEntity>> call(File imageFile) async {
    return await repository.updateProfilePicture(imageFile);
  }
}
