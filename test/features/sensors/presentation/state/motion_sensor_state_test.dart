import 'package:event_planner/features/sensors/presentation/state/motion_sensor_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MotionSensorState', () {
    test('default values are stable', () {
      const state = MotionSensorState();
      expect(state.isListening, isFalse);
      expect(state.tiltDirection, 'stable');
      expect(state.shakeCount, 0);
    });

    test('copyWith updates only provided fields', () {
      const state = MotionSensorState();
      final updated = state.copyWith(
        isListening: true,
        gyroX: 1.5,
        shakeDetected: true,
      );

      expect(updated.isListening, isTrue);
      expect(updated.gyroX, 1.5);
      expect(updated.shakeDetected, isTrue);
      expect(updated.gyroY, state.gyroY);
      expect(updated.tiltDirection, state.tiltDirection);
    });
  });
}
