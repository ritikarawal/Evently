import 'package:event_planner/features/payments/data/repositories/payment_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class TransactionHistoryScreen extends ConsumerWidget {
  const TransactionHistoryScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: FutureBuilder(
        future: ref.read(paymentRepositoryProvider).getUserPayments(userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final either = snapshot.data!;
          return either.fold((failure) => Center(child: Text(failure.message)), (
            list,
          ) {
            if (list.isEmpty) {
              return const Center(child: Text('No transactions yet'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = list[index];
                final status = (item['paymentStatus'] ?? '').toString();
                final isSuccess = status == 'Success';
                final createdAt = DateTime.tryParse(
                  (item['createdAt'] ?? '').toString(),
                );

                return Card(
                  child: ListTile(
                    title: Text(
                      'Txn: ${(item['transactionId'] ?? '-').toString()}',
                    ),
                    subtitle: Text(
                      '${item['amount'] ?? 0} NPR • ${createdAt == null ? '-' : DateFormat('MMM d, yyyy h:mm a').format(createdAt.toLocal())}',
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSuccess
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: isSuccess
                              ? Colors.green.shade800
                              : Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          });
        },
      ),
    );
  }
}
