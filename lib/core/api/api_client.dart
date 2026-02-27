import 'package:dio/dio.dart';
import 'package:event_planner/core/api/api_endpoints.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:event_planner/features/auth/data/repositories/auth_repository_impl.dart';

/// Provider for Dio instance
final dioProvider = Provider<Dio>((ref) {
  final userSessionService = ref.read(userSessionServiceProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: ApiEndpoints.connectionTimeout,
      receiveTimeout: ApiEndpoints.receiveTimeout,
      headers: {'Accept': 'application/json'},
    ),
  );

  // Add auth interceptor to automatically include token
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        // Get token from session
        final token = userSessionService.getCurrentUserToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          print('🔑 Auth token added to request: ${options.path}');
        } else {
          print('⚠️ No token found for request: ${options.path}');
        }

        // Don't override Content-Type for FormData (multipart/form-data)
        if (options.data is! FormData) {
          options.headers['Content-Type'] = 'application/json';
        }

        return handler.next(options);
      },
    ),
  );

  // Add pretty logger for development
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

/// Provider for ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.read(dioProvider));
});

/// API Client for handling HTTP requests
class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  /// GET request
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _executeWithFallback(
      () => _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  /// POST request
  Future<Response> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _executeWithFallback(
      () => _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  /// PUT request
  Future<Response> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _executeWithFallback(
      () => _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  /// PATCH request
  Future<Response> patch(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _executeWithFallback(
      () => _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  /// DELETE request
  Future<Response> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _executeWithFallback(
      () => _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  /// Execute a request and if a connection error occurs, attempt alternate
  /// base URLs (useful when switching between emulator, localhost, and
  /// physical device IPs). If a fallback succeeds, the Dio instance baseUrl
  /// is updated to the working URL.
  Future<Response> _executeWithFallback(
    Future<Response> Function() requestFn,
  ) async {
    try {
      return await requestFn();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        final originalBase = _dio.options.baseUrl;

        final candidates = <String>{
          ApiEndpoints.baseUrl,
          // localhost variation
          originalBase.replaceAll(
            RegExp(r'http://[^:/]+'),
            'http://localhost:5050',
          ),
          // Android emulator mapping
          originalBase.replaceAll(
            RegExp(r'http://[^:/]+'),
            'http://10.0.2.2:5050',
          ),
        }..removeWhere((s) => s == null || s.isEmpty);

        for (final candidate in candidates) {
          if (candidate == originalBase) continue;
          try {
            _dio.options.baseUrl = candidate;
            final res = await requestFn();
            // success — keep this base for future
            return res;
          } catch (_) {
            // continue trying other candidates
          }
        }

        // restore original base URL if no candidate worked
        _dio.options.baseUrl = originalBase;
      }

      // propagate a friendly error
      throw _handleError(e);
    }
  }

  /// Handle Dio errors and convert to user-friendly messages
  Exception _handleError(DioException error) {
    String errorMessage;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage =
            'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = 'Send timeout. Please try again.';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Receive timeout. Please try again.';
        break;
      case DioExceptionType.badResponse:
        errorMessage = _handleStatusCode(error.response?.statusCode);
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request was cancelled.';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'No internet connection. Please check your network.';
        break;
      default:
        errorMessage = 'An unexpected error occurred: ${error.message}';
    }

    return Exception(errorMessage);
  }

  /// Handle HTTP status codes
  String _handleStatusCode(int? statusCode) {
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

  /// Set authorization token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Remove authorization token
  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// Update base URL (useful for switching environments)
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }
}
