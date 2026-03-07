import 'package:event_planner/core/providers/shared_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum EventPaymentStatus { unpaid, paid }

class PaymentStatusLocalDataSource {
  PaymentStatusLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  String _key(String eventId, String userId) =>
      'event_payment_status_${eventId}_$userId';

  EventPaymentStatus getStatus({
    required String eventId,
    required String userId,
  }) {
    final raw = _prefs.getString(_key(eventId, userId)) ?? 'unpaid';
    return raw == 'paid' ? EventPaymentStatus.paid : EventPaymentStatus.unpaid;
  }

  Future<void> setStatus({
    required String eventId,
    required String userId,
    required EventPaymentStatus status,
  }) {
    return _prefs.setString(
      _key(eventId, userId),
      status == EventPaymentStatus.paid ? 'paid' : 'unpaid',
    );
  }

  Future<void> clearStatus({required String eventId, required String userId}) {
    return _prefs.remove(_key(eventId, userId));
  }
}

final paymentStatusLocalDataSourceProvider =
    Provider<PaymentStatusLocalDataSource>((ref) {
      final prefs = ref.read(sharedPreferencesProvider);
      return PaymentStatusLocalDataSource(prefs);
    });
