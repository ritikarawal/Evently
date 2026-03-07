import 'package:dartz/dartz.dart';
import 'package:event_planner/core/error/failures.dart';
import 'package:event_planner/features/payments/domain/entities/payment_result_entity.dart';

abstract class PaymentRepository {
  Future<Either<Failure, PaymentResultEntity>> verifyKhaltiPayment({
    required String token,
    required int amount,
    required String eventId,
    required String userId,
  });
}
