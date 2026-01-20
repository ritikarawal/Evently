import 'package:dartz/dartz.dart';
import 'package:event_planner/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:event_planner/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_entity.dart';

final getUserByEmailProvider = Provider(
  (ref) => GetUserByEmailUsecase(ref.read(authRepositoryProvider)),
);

class GetUserByEmailUsecase {
  final IAuthRepository repository;
  GetUserByEmailUsecase(this.repository);
  Future<Either<Failure, AuthEntity>> call(String email) {
    return repository.getUserByEmail(email);
  }
}
