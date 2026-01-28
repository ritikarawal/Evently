import 'package:event_planner/features/auth/data/models/auth_api_model.dart';
import 'package:event_planner/features/auth/data/models/auth_hive_model.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

abstract interface class IAuthLocalDataSource {
  Future<AuthHiveModel> register(AuthHiveModel user);
  Future<AuthHiveModel?> login(String email, String password);
  Future<AuthHiveModel?> getCurrentUser();
  Future<bool> logout();
  Future<AuthHiveModel?> getUserById(String id);
  Future<AuthHiveModel?> getUserByEmail(String email);
  Future<bool> updateUser(AuthHiveModel user);
  Future<bool> deleteUser(String id);
}

abstract interface class IAuthRemoteDataSource {
  Future<AuthApiModel> register(AuthApiModel user);
  Future<AuthApiModel?> login(String email, String password);
  Future<AuthApiModel?> getUserById(String id);
  Future<AuthApiModel?> getUserByEmail(String email);
  Future<AuthApiModel?> updateProfilePicture(File imageFile);
}

class AuthDataSource {
  final ImagePicker _picker = ImagePicker();

  Future<void> uploadProfilePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Implement your upload logic here
      // For example, upload to your backend or cloud storage
    }
  }
}
