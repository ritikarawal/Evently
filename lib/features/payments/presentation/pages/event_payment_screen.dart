import 'package:event_planner/features/payments/data/datasources/payment_status_local_datasource.dart';
import 'package:event_planner/features/payments/domain/usecases/verify_khalti_payment_usecase.dart';
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
  final _tokenController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _verifyPayment() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter Khalti token')));
      return;
    }

    setState(() => _isSubmitting = true);

    final usecase = ref.read(verifyKhaltiPaymentUsecaseProvider);
    final result = await usecase(
      VerifyKhaltiPaymentParams(
        token: token,
        amount: widget.amount,
        eventId: widget.eventId,
        userId: widget.userId,
      ),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              failure.message.isEmpty ? 'Payment failed' : failure.message,
            ),
          ),
        );
      },
      (paymentResult) async {
        if (paymentResult.success) {
          final statusStore = ref.read(paymentStatusLocalDataSourceProvider);
          await statusStore.setStatus(
            eventId: widget.eventId,
            userId: widget.userId,
            status: EventPaymentStatus.paid,
          );

          if (!mounted) return;
          Navigator.pop(context, true);
          return;
        }

        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              paymentResult.message.isEmpty
                  ? 'Payment verification failed'
                  : paymentResult.message,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Payment')),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 8),
            Text(
              'Amount: NPR ${widget.amount}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Enter Khalti token from your payment flow to verify and mark this event as paid.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tokenController,
              decoration: const InputDecoration(
                labelText: 'Khalti Token',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _verifyPayment,
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
                    : const Text('Verify Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
