import 'package:dartz/dartz.dart';
import 'package:event_planner/features/auth/data/datasources/local/auth_localdatasource.dart';
import 'package:event_planner/core/services/storage/user_session_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/failures.dart';
import '../models/auth_hive_model.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';

// Create provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authDatasource = ref.read(authLocalDataSourceProvider);
  final sessionService = ref.read(userSessionServiceProvider);
  return AuthRepository(
    authDatasource: authDatasource,
    sessionService: sessionService,
  );
});

class AuthRepository implements IAuthRepository {
  final AuthLocalDataSource _authDataSource;
  final UserSessionService _sessionService;

  AuthRepository({
    required AuthLocalDataSource authDatasource,
    required UserSessionService sessionService,
  }) : _authDataSource = authDatasource,
       _sessionService = sessionService;

  @override
  Future<Either<Failure, bool>> register(AuthEntity user) async {
    try {
      // 1. Check if user already exists in Hive
      final existingUser = await _authDataSource.getUserByEmail(user.email);
      if (existingUser != null) {
        return const Left(
          LocalDatabaseFailure(
            message: "This email is already registered with PeerPicks",
          ),
        );
      }

      // 2. Convert Entity to Hive Model using factory for cleaner code
      final authModel = AuthHiveModel.fromEntity(user);

      await _authDataSource.register(authModel);
      return const Right(true);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    try {
      final model = await _authDataSource.login(email, password);
      if (model != null) {
        // Save user session
        await _sessionService.saveUserSession(
          userId: model.authId!,
          email: model.email,
          fullName: model.fullName,
          username: model.username,
          phoneNumber: model.phoneNumber,
          profilePicture: model.profilePicture,
        );
        // Convert Hive Model back to Domain Entity for the UI
        return Right(model.toEntity());
      }
      return const Left(
        LocalDatabaseFailure(message: "Invalid credentials. Please try again."),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final model = await _authDataSource.getCurrentUser();
      if (model != null) {
        return Right(model.toEntity());
      }
      return const Left(LocalDatabaseFailure(message: "Session expired"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      // Clear session first
      await _sessionService.clearSession();
      final result = await _authDataSource.logout();
      return Right(result);
    } catch (e) {
      return Left(
        LocalDatabaseFailure(message: "Logout failed: ${e.toString()}"),
      );
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getUserByEmail(String email) async {
    try {
      final model = await _authDataSource.getUserByEmail(email);
      if (model != null) {
        return Right(model.toEntity());
      }
      return const Left(
        LocalDatabaseFailure(message: "No user found with this email"),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}
