import 'package:equatable/equatable.dart';

class PaymentResultEntity extends Equatable {
  final bool success;
  final String message;

  const PaymentResultEntity({this.success = false, this.message = ''});

  @override
  List<Object?> get props => [success, message];
}
