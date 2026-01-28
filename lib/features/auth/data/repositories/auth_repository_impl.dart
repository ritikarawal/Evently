import 'dart:io'; // Add this import
import 'package:dartz/dartz.dart';
import 'package:event_planner/core/error/failures.dart';
import 'package:event_planner/core/services/connectivity/network_info.dart';
import 'package:event_planner/features/auth/data/datasources/auth_datasource.dart';
import 'package:event_planner/features/auth/data/models/auth_api_model.dart';
import 'package:event_planner/features/auth/data/models/auth_hive_model.dart';
import 'package:event_planner/features/auth/domain/entities/auth_entity.dart';
import 'package:event_planner/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:event_planner/core/services/storage/user_session_service.dart';
import 'package:event_planner/core/providers/shared_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../datasources/local/auth_localdatasource.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/services/hive/hive_service.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthRemoteDataSource _remoteDataSource;
  final IAuthLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  final UserSessionService _userSessionService;

  AuthRepositoryImpl({
    required IAuthRemoteDataSource remoteDataSource,
    required IAuthLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
    required UserSessionService userSessionService,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo,
       _userSessionService = userSessionService;

  @override
  Future<Either<Failure, bool>> register(AuthEntity user) async {
    try {
      if (await _networkInfo.isConnected) {
        // Call remote API
        final apiModel = AuthApiModel(
          fullName: user.fullName,
          email: user.email,
          username: user.username,
          phoneNumber: user.phoneNumber,
          password: user.password,
        );

        final result = await _remoteDataSource.register(apiModel);
        // Save to local database
        final hiveModel = AuthHiveModel(
          authId: result.id,
          fullName: result.fullName,
          email: result.email,
          username: result.username ?? result.email.split('@')[0],
          phoneNumber: result.phoneNumber,
          password: result.password,
          profilePicture: result.id,
        );
        await _localDataSource.register(hiveModel);

        // Save session if token is present
        if (result.token != null && result.id != null) {
          await _userSessionService.saveUserSession(
            userId: result.id!,
            email: result.email,
            fullName: result.fullName,
            username: result.username ?? '',
            phoneNumber: result.phoneNumber,
            profilePicture: result.profilePicture,
            token: result.token,
          );
        }

        return const Right(true);
      } else {
        return Left(NetworkFailure(message: 'No internet connection'));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    try {
      if (await _networkInfo.isConnected) {
        // Call remote API
        final result = await _remoteDataSource.login(email, password);
        if (result != null) {
          // Save to local database
          final hiveModel = AuthHiveModel(
            authId: result.id,
            fullName: result.fullName,
            email: result.email,
            username: result.username ?? email.split('@')[0],
            phoneNumber: result.phoneNumber,
            password: result.password,
          );
          await _localDataSource.login(email, password);

          // Save session if token is present
          if (result.token != null && result.id != null) {
            await _userSessionService.saveUserSession(
              userId: result.id!,
              email: result.email,
              fullName: result.fullName,
              username: result.username ?? email.split('@')[0],
              phoneNumber: result.phoneNumber,
              profilePicture: result.profilePicture,
              token: result.token,
            );
          }

          return Right(result.toEntity());
        }
        return Left(ServerFailure(message: 'Login failed'));
      } else {
        return Left(NetworkFailure(message: 'No internet connection'));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity?>> getCurrentUser() async {
    try {
      if (!_userSessionService.isLoggedIn()) {
        return const Right(null);
      }

      final userId = _userSessionService.getCurrentUserId();
      final email = _userSessionService.getCurrentUserEmail();
      final fullName = _userSessionService.getCurrentUserFullName();
      final username = _userSessionService.getCurrentUserUsername();
      final phoneNumber = _userSessionService.getCurrentUserPhoneNumber();
      final profilePicture = _userSessionService.getCurrentUserProfilePicture();

      if (userId == null || email == null || fullName == null) {
        return const Right(null);
      }

      // Build entity from session data
      final user = AuthEntity(
        email: email,
        fullName: fullName,
        username: username ?? email.split('@')[0],
        phoneNumber: phoneNumber,
        profilePicture: profilePicture,
      );

      return Right(user);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      await _userSessionService.clearSession();
      return const Right(true);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getUserByEmail(String email) async {
    try {
      if (await _networkInfo.isConnected) {
        final result = await _remoteDataSource.getUserByEmail(email);
        if (result != null) {
          return Right(result.toEntity());
        }
        return Left(ServerFailure(message: 'User not found'));
      } else {
        final localUser = await _localDataSource.getUserByEmail(email);
        if (localUser != null) {
          return Right(localUser.toEntity());
        }
        return Left(NetworkFailure(message: 'No internet connection'));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // Add this new method
  @override
  Future<Either<Failure, AuthEntity>> updateProfilePicture(
    File imageFile,
  ) async {
    try {
      if (await _networkInfo.isConnected) {
        // Call remote API to update profile picture
        final result = await _remoteDataSource.updateProfilePicture(imageFile);

        if (result != null) {
          // Update session with new profile picture
          await _userSessionService.saveUserSession(
            userId: result.id!,
            email: result.email,
            fullName: result.fullName,
            username: result.username ?? result.email.split('@')[0],
            phoneNumber: result.phoneNumber,
            profilePicture: result.profilePicture,
            token: _userSessionService.getCurrentUserToken(),
          );

          // Update local database with new profile picture
          final userId = _userSessionService.getCurrentUserId();
          if (userId != null) {
            final hiveModel = AuthHiveModel(
              authId: result.id,
              fullName: result.fullName,
              email: result.email,
              username: result.username ?? result.email.split('@')[0],
              phoneNumber: result.phoneNumber,
              password: result.password,
              profilePicture: result.profilePicture, // Update profile picture
            );

            // Update local storage
            await _localDataSource.updateUser(hiveModel);
          }

          return Right(result.toEntity());
        }
        return Left(ServerFailure(message: 'Failed to update profile picture'));
      } else {
        return Left(NetworkFailure(message: 'No internet connection'));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

// Providers
final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return UserSessionService(prefs: prefs);
});

final authRemoteDataSourceProvider = Provider<IAuthRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);
  return AuthRemoteDataSource(dio);
});

final authLocalDataSourceProvider = Provider<IAuthLocalDataSource>((ref) {
  final sessionService = ref.read(userSessionServiceProvider);
  final hiveService = ref.read(hiveServiceProvider);
  return AuthLocalDataSource(
    hiveService: hiveService,
    userSessionService: sessionService,
  );
});

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final remoteDataSource = ref.read(authRemoteDataSourceProvider);
  final localDataSource = ref.read(authLocalDataSourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  final userSessionService = ref.read(userSessionServiceProvider);

  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    networkInfo: networkInfo,
    userSessionService: userSessionService,
  );
});
