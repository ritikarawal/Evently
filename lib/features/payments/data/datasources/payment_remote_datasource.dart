import 'package:dio/dio.dart';
import 'package:event_planner/core/api/api_endpoints.dart';

class PaymentRemoteDataSource {
  final Dio _dio;

  PaymentRemoteDataSource(this._dio);

  Future<Map<String, dynamic>> verifyKhaltiPayment({
    required String token,
    required int amount,
    required String eventId,
    required String userId,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.khaltiVerify,
      data: {
        'token': token,
        'amount': amount,
        'eventId': eventId,
        'userId': userId,
      },
    );

    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }

    return {'success': false, 'message': 'Invalid payment response'};
  }
}
