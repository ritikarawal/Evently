import 'package:event_planner/core/services/hive/hive_service.dart';
import 'package:event_planner/core/services/storage/user_session_service.dart';
import 'package:event_planner/features/auth/data/datasources/auth_datasource.dart';
import 'package:event_planner/features/auth/data/models/auth_hive_model.dart';

class AuthLocalDataSource implements IAuthLocalDataSource {
  final HiveService _hiveService;
  final UserSessionService _userSessionService;

  AuthLocalDataSource({
    required HiveService hiveService,
    required UserSessionService userSessionService,
  }) : _hiveService = hiveService,
       _userSessionService = userSessionService;

  @override
  Future<AuthHiveModel> register(AuthHiveModel user) async {
    await _hiveService.register(user);
    return user;
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    final user = _hiveService.login(email, password);

    if (user != null && user.authId != null) {
      await _userSessionService.saveUserSession(
        userId: user.authId!,
        email: user.email,
        fullName: user.fullName,
        username: user.username,
        phoneNumber: user.phoneNumber,
        profilePicture: user.profilePicture,
      );
    }
    return user;
  }

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    if (!_userSessionService.isLoggedIn()) return null;

    final userId = _userSessionService.getCurrentUserId();
    if (userId == null) return null;

    return _hiveService.getUserById(userId);
  }

  @override
  Future<bool> logout() async {
    await _userSessionService.clearSession();
    return true;
  }

  @override
  Future<AuthHiveModel?> getUserById(String id) async =>
      _hiveService.getUserById(id);

  @override
  Future<AuthHiveModel?> getUserByEmail(String email) async =>
      _hiveService.getUserByEmail(email);

  @override
  Future<bool> updateUser(AuthHiveModel user) => _hiveService.updateUser(user);

  @override
  Future<bool> deleteUser(String id) async {
    await _hiveService.deleteUser(id);
    return true;
  }
}
