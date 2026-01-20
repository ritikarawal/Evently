import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:event_planner/core/error/failures.dart';
import 'package:event_planner/core/usecases/app_usecases.dart';
import 'package:event_planner/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:event_planner/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../entities/auth_entity.dart';

class RegisterParams extends Equatable {
  final String fullName;
  final String email;
  final String username;
  final String password;
  final String confirmPassword;
  final String? phoneNumber;

  const RegisterParams({
    required this.fullName,
    required this.email,
    required this.username,
    required this.password,
    required this.confirmPassword,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [
    fullName,
    email,
    username,
    password,
    confirmPassword,
    phoneNumber,
  ];
}

final registerUsecaseProvider = Provider<RegisterUseCase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return RegisterUseCase(authRepository: authRepository);
});

class RegisterUseCase implements UsecaseWithParms<bool, RegisterParams> {
  final IAuthRepository _authRepository;

  RegisterUseCase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterParams params) {
    final authEntity = AuthEntity(
      fullName: params.fullName,
      email: params.email,
      username: params.username,
      password: params.password,
      phoneNumber: params.phoneNumber,
    );

    return _authRepository.register(authEntity);
  }
}
