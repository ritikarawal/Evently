import 'dart:io';
import 'package:dio/dio.dart';
import 'package:event_planner/core/api/api_endpoints.dart';
import 'package:event_planner/features/auth/data/datasources/auth_datasource.dart';
import 'package:event_planner/features/auth/data/models/auth_api_model.dart';

class AuthRemoteDataSource implements IAuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.userLogin,
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final userData = responseData['data'] as Map<String, dynamic>;
        userData['token'] =
            responseData['token']; // Capture token from root level
        return AuthApiModel.fromJson(userData);
      } else if (response.statusCode == 401) {
        print('Login error: Invalid credentials');
        throw Exception('Invalid email or password');
      } else {
        print('Login error: Server error - ${response.statusCode}');
        throw Exception('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Login error: ${e.message} - Response: ${e.response?.data}');
      rethrow;
    }
  }

  @override
  Future<AuthApiModel> register(AuthApiModel model) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.userRegister,
        data: model.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final userData = responseData['data'] as Map<String, dynamic>;
        userData['token'] =
            responseData['token']; // Capture token from root level
        return AuthApiModel.fromJson(userData);
      } else if (response.statusCode == 400) {
        print('Register error: Invalid data - ${response.data}');
        throw Exception(
          response.data['message'] ?? 'Invalid registration data',
        );
      } else if (response.statusCode == 409) {
        print('Register error: User already exists');
        throw Exception('User already exists');
      } else {
        print('Register error: Server error - ${response.statusCode}');
        throw Exception('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Register error: ${e.message} - Response: ${e.response?.data}');
      rethrow;
    }
  }

  @override
  Future<AuthApiModel?> getUserById(String id) async {
    try {
      final response = await _dio.get('${ApiEndpoints.userById}$id');

      if (response.statusCode == 200) {
        final userData = response.data['data'] as Map<String, dynamic>;
        return AuthApiModel.fromJson(userData);
      }
      return null;
    } on DioException catch (e) {
      print('Get user by ID error: ${e.message}');
      rethrow;
    }
  }

  @override
  Future<AuthApiModel?> getUserByEmail(String email) async {
    try {
      final response = await _dio.get('${ApiEndpoints.userByEmail}$email');

      if (response.statusCode == 200) {
        final userData = response.data['data'] as Map<String, dynamic>;
        return AuthApiModel.fromJson(userData);
      }
      return null;
    } on DioException catch (e) {
      print('Get user by email error: ${e.message}');
      rethrow;
    }
  }

  @override
  Future<AuthApiModel?> updateProfilePicture(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imageFile.path),
      });

      final response = await _dio.post(
        ApiEndpoints.updateProfilePicture,
        data: formData,
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final userData = responseData['data'] as Map<String, dynamic>;
        return AuthApiModel.fromJson(userData);
      }
      return null;
    } on DioException catch (e) {
      print('Update profile picture error: ${e.message}');
      rethrow;
    }
  }
}
