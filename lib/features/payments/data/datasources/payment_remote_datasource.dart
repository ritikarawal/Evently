import 'package:dio/dio.dart';
import 'package:event_planner/core/api/api_endpoints.dart';

class PaymentRemoteDataSource {
  final Dio _dio;

  PaymentRemoteDataSource(this._dio);

  Future<Map<String, dynamic>> createDemoPayment({
    required String userId,
    required String eventId,
    required int amount,
    required String paymentMethod,
    required String cardHolderName,
    required String cardNumber,
    required String expiryDate,
    required String cvv,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.paymentCreate,
      data: {
        'userId': userId,
        'eventId': eventId,
        'amount': amount,
        'paymentMethod': paymentMethod,
        'cardHolderName': cardHolderName,
        'cardNumber': cardNumber,
        'expiryDate': expiryDate,
        'cvv': cvv,
      },
    );

    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }

    return {'success': false, 'message': 'Invalid payment response'};
  }

  Future<List<Map<String, dynamic>>> getUserPayments(String userId) async {
    final response = await _dio.get(ApiEndpoints.paymentsByUser(userId));
    final body = response.data;
    if (body is Map<String, dynamic> && body['data'] is List) {
      return (body['data'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const [];
  }
}
