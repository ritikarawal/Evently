import 'package:dio/dio.dart';
import 'package:event_planner/core/api/api_endpoints.dart';
import 'package:event_planner/core/services/storage/user_session_service.dart';
import 'package:event_planner/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

final dioProvider = Provider<Dio>((ref) {
  final userSessionService = ref.read(userSessionServiceProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: ApiEndpoints.connectionTimeout,
      receiveTimeout: ApiEndpoints.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = userSessionService.getCurrentUserToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        } else {
          final path = options.path.toLowerCase();
          final isPublicAuthCall =
              path.contains('auth/login') || path.contains('auth/register');
          if (!isPublicAuthCall) {
            debugPrint('No token found for request: ${options.path}');
          }
        }
        handler.next(options);
      },
    ),
  );

  dio.interceptors.add(
    PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
    ),
  );

  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.read(dioProvider), ref.read(userSessionServiceProvider));
});

class ApiClient {
  final Dio _dio;
  final UserSessionService _userSessionService;

  ApiClient(this._dio, this._userSessionService);

  Future<Response<dynamic>> request({
    required String method,
    required String endpoint,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.request(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: (options ?? Options()).copyWith(method: method),
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Response<dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return request(
      method: 'GET',
      endpoint: endpoint,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<dynamic>> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return request(
      method: 'POST',
      endpoint: endpoint,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<dynamic>> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return request(
      method: 'PUT',
      endpoint: endpoint,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<dynamic>> patch(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return request(
      method: 'PATCH',
      endpoint: endpoint,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<dynamic>> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return request(
      method: 'DELETE',
      endpoint: endpoint,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Exception _mapError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return Exception(
          'Connection timeout. Please check your internet connection.',
        );
      case DioExceptionType.sendTimeout:
        return Exception('Send timeout. Please try again.');
      case DioExceptionType.receiveTimeout:
        return Exception('Receive timeout. Please try again.');
      case DioExceptionType.badResponse:
        return Exception(_statusMessage(error.response?.statusCode));
      case DioExceptionType.cancel:
        return Exception('Request was cancelled.');
      case DioExceptionType.connectionError:
        return Exception(
          'Network connection failed. Please check your internet and backend URL.',
        );
      default:
        return Exception('An unexpected error occurred: ${error.message}');
    }
  }

  String _statusMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Forbidden. You don\'t have permission.';
      case 404:
        return 'Resource not found.';
      case 500:
        return 'Internal server error. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'Something went wrong. Status code: $statusCode';
    }
  }

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<void> removeAuthToken() async {
    _dio.options.headers.remove('Authorization');
    await _userSessionService.clearSession();
  }

  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = ApiEndpoints.normalizeApiBase(newBaseUrl);
  }
}
