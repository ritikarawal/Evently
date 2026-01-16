import 'package:dartz/dartz.dart';
import 'package:event_planner/core/error/failures.dart';
import 'package:event_planner/core/usecases/app_usecases.dart';
import 'package:event_planner/features/auth/domain/entities/auth_entity.dart';
import 'package:event_planner/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:event_planner/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for GetCurrentUserUsecase
final getCurrentUserUsecaseProvider = Provider<GetCurrentUserUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return GetCurrentUserUsecase(authRepository: authRepository);
});

/// Use case for getting the current logged-in user
class GetCurrentUserUsecase implements UsecaseWithoutParms<AuthEntity?> {
  final IAuthRepository _authRepository;

  GetCurrentUserUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, AuthEntity?>> call() async {
    final result = await _authRepository.getCurrentUser();
    return result;
  }
}
