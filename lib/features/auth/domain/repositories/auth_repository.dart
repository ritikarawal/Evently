import 'package:event_planner/features/auth/domain/entities/auth_entity.dart';

abstract class AuthRepository {
  Future<AuthEntity> login(String email, String password);
  Future<AuthEntity> register({
    required String name,
    required String email,
    required String password,
    String? preference,
  });
  Future<AuthEntity?> getCurrentUser();
  Future<bool> isLoggedIn();
  Future<void> logout();
}
