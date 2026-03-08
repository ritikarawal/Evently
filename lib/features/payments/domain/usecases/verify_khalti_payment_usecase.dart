import 'package:dartz/dartz.dart';
import 'package:event_planner/core/error/failures.dart';
import 'package:event_planner/features/payments/data/repositories/payment_repository_impl.dart';
import 'package:event_planner/features/payments/domain/entities/payment_result_entity.dart';
import 'package:event_planner/features/payments/domain/repositories/payment_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VerifyKhaltiPaymentParams {
  final String userId;
  final String eventId;
  final int amount;
  final String paymentMethod;
  final String cardHolderName;
  final String cardNumber;
  final String expiryDate;
  final String cvv;

  const VerifyKhaltiPaymentParams({
    required this.userId,
    required this.eventId,
    required this.amount,
    this.paymentMethod = 'Card',
    required this.cardHolderName,
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
  });
}

class VerifyKhaltiPaymentUsecase {
  final PaymentRepository _repository;

  VerifyKhaltiPaymentUsecase(this._repository);

  Future<Either<Failure, PaymentResultEntity>> call(
    VerifyKhaltiPaymentParams params,
  ) {
    return _repository.createDemoPayment(
      userId: params.userId,
      eventId: params.eventId,
      amount: params.amount,
      paymentMethod: params.paymentMethod,
      cardHolderName: params.cardHolderName,
      cardNumber: params.cardNumber,
      expiryDate: params.expiryDate,
      cvv: params.cvv,
    );
  }
}

final verifyKhaltiPaymentUsecaseProvider = Provider<VerifyKhaltiPaymentUsecase>(
  (ref) {
    final repo = ref.read(paymentRepositoryProvider);
    return VerifyKhaltiPaymentUsecase(repo);
  },
);
