import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:event_planner/core/error/failures.dart';
import 'package:event_planner/features/auth/domain/entities/auth_entity.dart';
import 'package:event_planner/features/auth/domain/entities/update_profile_params.dart';

abstract interface class IAuthRepository {
  Future<Either<Failure, bool>> register(AuthEntity user);
  Future<Either<Failure, AuthEntity>> login(String email, String password);
  Future<Either<Failure, AuthEntity?>> getCurrentUser();
  Future<Either<Failure, bool>> logout();
  Future<Either<Failure, AuthEntity>> getUserByEmail(String email);
  Future<Either<Failure, AuthEntity>> updateProfile(UpdateProfileParams params);

  Future<Either<Failure, AuthEntity>> updateProfilePicture(File imageFile);
}
