import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:event_planner/core/error/failures.dart';
import 'package:event_planner/core/usecases/app_usecases.dart';
import 'package:event_planner/features/auth/data/repositories/auth_repository.dart';
import 'package:event_planner/features/auth/domain/entities/auth_entity.dart';
import 'package:event_planner/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return LoginUseCase(authRepository: authRepository);
});

class LoginUseCase implements UsecaseWithParms<AuthEntity, LoginParams> {
  final IAuthRepository _authRepository;

  LoginUseCase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call(LoginParams params) {
    return _authRepository.login(params.email, params.password);
  }
}
