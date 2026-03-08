import 'package:event_planner/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Failures', () {
    test('LocalDatabaseFailure has default message', () {
      const failure = LocalDatabaseFailure();
      expect(failure.message, 'Local Database Failure');
    });

    test('ApiFailure stores message and status code', () {
      const failure = ApiFailure(message: 'Unauthorized', statusCode: 401);
      expect(failure.message, 'Unauthorized');
      expect(failure.statusCode, 401);
    });

    test('ServerFailure equality uses message', () {
      const a = ServerFailure(message: 'Server down');
      const b = ServerFailure(message: 'Server down');
      expect(a, b);
    });

    test('NetworkFailure has default message', () {
      const failure = NetworkFailure();
      expect(failure.message, 'Network Failure');
    });
  });
}
