import 'package:dartz/dartz.dart';
import 'package:event_planner/core/error/failures.dart';
import 'package:event_planner/features/payments/data/repositories/payment_repository_impl.dart';
import 'package:event_planner/features/payments/domain/entities/payment_result_entity.dart';
import 'package:event_planner/features/payments/domain/repositories/payment_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VerifyKhaltiPaymentParams {
  final String token;
  final int amount;
  final String eventId;
  final String userId;

  const VerifyKhaltiPaymentParams({
    required this.token,
    required this.amount,
    required this.eventId,
    required this.userId,
  });
}

class VerifyKhaltiPaymentUsecase {
  final PaymentRepository _repository;

  VerifyKhaltiPaymentUsecase(this._repository);

  Future<Either<Failure, PaymentResultEntity>> call(
    VerifyKhaltiPaymentParams params,
  ) {
    return _repository.verifyKhaltiPayment(
      token: params.token,
      amount: params.amount,
      eventId: params.eventId,
      userId: params.userId,
    );
  }
}

final verifyKhaltiPaymentUsecaseProvider = Provider<VerifyKhaltiPaymentUsecase>(
  (ref) {
    final repo = ref.read(paymentRepositoryProvider);
    return VerifyKhaltiPaymentUsecase(repo);
  },
);
