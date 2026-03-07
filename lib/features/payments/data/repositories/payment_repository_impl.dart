import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:event_planner/core/api/api_client.dart';
import 'package:event_planner/core/error/failures.dart';
import 'package:event_planner/features/payments/data/datasources/payment_remote_datasource.dart';
import 'package:event_planner/features/payments/domain/entities/payment_result_entity.dart';
import 'package:event_planner/features/payments/domain/repositories/payment_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final paymentRemoteDataSourceProvider = Provider<PaymentRemoteDataSource>((
  ref,
) {
  final dio = ref.read(dioProvider);
  return PaymentRemoteDataSource(dio);
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final remote = ref.read(paymentRemoteDataSourceProvider);
  return PaymentRepositoryImpl(remote);
});

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource _remote;

  PaymentRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, PaymentResultEntity>> verifyKhaltiPayment({
    required String token,
    required int amount,
    required String eventId,
    required String userId,
  }) async {
    try {
      final result = await _remote.verifyKhaltiPayment(
        token: token,
        amount: amount,
        eventId: eventId,
        userId: userId,
      );

      return Right(
        PaymentResultEntity(
          success: result['success'] == true,
          message: (result['message'] ?? '').toString(),
        ),
      );
    } on DioException catch (e) {
      return Left(
        ServerFailure(message: e.message ?? 'Payment verification failed'),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
