import 'package:event_planner/features/payments/domain/entities/payment_result_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PaymentResultEntity equality is value-based', () {
    const a = PaymentResultEntity(
      success: true,
      message: 'ok',
      paymentStatus: 'Success',
      transactionId: 'TX123',
    );
    const b = PaymentResultEntity(
      success: true,
      message: 'ok',
      paymentStatus: 'Success',
      transactionId: 'TX123',
    );

    expect(a, b);
  });
}
