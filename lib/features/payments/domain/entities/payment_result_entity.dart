import 'package:equatable/equatable.dart';

class PaymentResultEntity extends Equatable {
  final bool success;
  final String message;
  final String paymentStatus;
  final String transactionId;

  const PaymentResultEntity({
    this.success = false,
    this.message = '',
    this.paymentStatus = '',
    this.transactionId = '',
  });

  @override
  List<Object?> get props => [success, message, paymentStatus, transactionId];
}
