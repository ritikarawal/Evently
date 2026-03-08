import 'package:event_planner/features/payments/data/datasources/payment_status_local_datasource.dart';
import 'package:event_planner/features/payments/domain/usecases/verify_khalti_payment_usecase.dart';
import 'package:event_planner/features/payments/presentation/pages/payment_success_screen.dart';
import 'package:event_planner/features/payments/presentation/pages/transaction_history_screen.dart';
import 'package:event_planner/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventPaymentScreen extends ConsumerStatefulWidget {
  const EventPaymentScreen({
    super.key,
    required this.eventId,
    required this.userId,
    required this.eventTitle,
    required this.amount,
  });

  final String eventId;
  final String userId;
  final String eventTitle;
  final int amount;

  @override
  ConsumerState<EventPaymentScreen> createState() => _EventPaymentScreenState();
}

class _EventPaymentScreenState extends ConsumerState<EventPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cardController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _cardController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _payNow() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final usecase = ref.read(verifyKhaltiPaymentUsecaseProvider);
    final result = await usecase(
      VerifyKhaltiPaymentParams(
        userId: widget.userId,
        eventId: widget.eventId,
        amount: widget.amount,
        paymentMethod: 'Card',
        cardHolderName: _nameController.text.trim(),
        cardNumber: _cardController.text.trim(),
        expiryDate: _expiryController.text.trim(),
        cvv: _cvvController.text.trim(),
      ),
    );

    if (!mounted) return;

    result.fold(
      (failure) async {
        setState(() => _isSubmitting = false);
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Payment Failed'),
            content: Text(
              failure.message.isEmpty
                  ? 'Payment failed. Please retry.'
                  : failure.message,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      },
      (paymentResult) async {
        setState(() => _isSubmitting = false);

        if (paymentResult.success) {
          final statusStore = ref.read(paymentStatusLocalDataSourceProvider);
          await statusStore.setStatus(
            eventId: widget.eventId,
            userId: widget.userId,
            status: EventPaymentStatus.paid,
          );

          if (!mounted) return;
          final ok = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentSuccessScreen(
                transactionId: paymentResult.transactionId,
                eventTitle: widget.eventTitle,
                amount: widget.amount,
              ),
            ),
          );

          if (ok == true && mounted) {
            Navigator.pop(context, true);
          }
          return;
        }

        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Payment Failed'),
            content: Text(
              paymentResult.message.isEmpty
                  ? 'Payment failed. Please retry.'
                  : paymentResult.message,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Payment'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      TransactionHistoryScreen(userId: widget.userId),
                ),
              );
            },
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.eventTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _label('Card Holder Name'),
              _field(
                controller: _nameController,
                hint: 'John Doe',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Card holder name is required'
                    : null,
              ),
              const SizedBox(height: 12),
              _label('Card Number'),
              _field(
                controller: _cardController,
                hint: '4242 4242 4242 4242',
                keyboardType: TextInputType.number,
                validator: (v) {
                  final value = (v ?? '').replaceAll(' ', '');
                  if (value.length < 12 || value.length > 19) {
                    return 'Enter a valid card number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Expiry Date'),
                        _field(
                          controller: _expiryController,
                          hint: 'MM/YY',
                          validator: (v) {
                            final value = (v ?? '').trim();
                            if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                              return 'MM/YY';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('CVV'),
                        _field(
                          controller: _cvvController,
                          hint: '123',
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final value = (v ?? '').trim();
                            if (value.length < 3 || value.length > 4) {
                              return '3-4 digits';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _label('Amount'),
              TextFormField(
                initialValue: 'NPR ${widget.amount}',
                enabled: false,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _payNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Pay Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
