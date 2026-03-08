import 'package:dartz/dartz.dart';
import 'package:event_planner/core/error/failures.dart';
import 'package:event_planner/features/payments/domain/entities/payment_result_entity.dart';

abstract class PaymentRepository {
  Future<Either<Failure, PaymentResultEntity>> createDemoPayment({
    required String userId,
    required String eventId,
    required int amount,
    required String paymentMethod,
    required String cardHolderName,
    required String cardNumber,
    required String expiryDate,
    required String cvv,
  });

  Future<Either<Failure, List<Map<String, dynamic>>>> getUserPayments(
    String userId,
  );
}
