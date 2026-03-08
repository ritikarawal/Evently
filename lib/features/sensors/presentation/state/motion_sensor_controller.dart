import 'dart:async';
import 'dart:math' as math;

import 'package:event_planner/features/sensors/presentation/state/motion_sensor_state.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sensors_plus/sensors_plus.dart';

final motionSensorControllerProvider =
    StateNotifierProvider.autoDispose<
      MotionSensorController,
      MotionSensorState
    >((ref) {
      final controller = MotionSensorController();
      ref.onDispose(() {
        controller.stopListening();
      });
      return controller;
    });

class MotionSensorController extends StateNotifier<MotionSensorState> {
  MotionSensorController() : super(const MotionSensorState());

  static const double shakeThresholdG = 2.3;
  static const double gyroTiltThreshold = 1.0;

  StreamSubscription<GyroscopeEvent>? _gyroscopeSub;
  StreamSubscription<AccelerometerEvent>? _accelerometerSub;
  DateTime _lastShakeAt = DateTime.fromMillisecondsSinceEpoch(0);
  Timer? _shakeResetTimer;

  void startListening() {
    if (state.isListening) return;

    state = state.copyWith(isListening: true);

    _gyroscopeSub = gyroscopeEventStream().listen((event) {
      final tiltDirection = _resolveTiltDirection(event.x, event.y);
      state = state.copyWith(
        gyroX: event.x,
        gyroY: event.y,
        gyroZ: event.z,
        tiltDirection: tiltDirection,
      );
    });

    _accelerometerSub = accelerometerEventStream().listen((event) {
      state = state.copyWith(accelX: event.x, accelY: event.y, accelZ: event.z);

      _detectShake(event);
    });
  }

  Future<void> stopListening() async {
    _shakeResetTimer?.cancel();
    await _gyroscopeSub?.cancel();
    await _accelerometerSub?.cancel();
    _gyroscopeSub = null;
    _accelerometerSub = null;

    if (mounted) {
      state = state.copyWith(isListening: false, shakeDetected: false);
    }
  }

  String _resolveTiltDirection(double gyroX, double gyroY) {
    if (gyroY > gyroTiltThreshold) return 'tilt-right';
    if (gyroY < -gyroTiltThreshold) return 'tilt-left';
    if (gyroX > gyroTiltThreshold) return 'tilt-forward';
    if (gyroX < -gyroTiltThreshold) return 'tilt-backward';
    return 'stable';
  }

  void _detectShake(AccelerometerEvent event) {
    final magnitude = math.sqrt(
      (event.x * event.x) + (event.y * event.y) + (event.z * event.z),
    );
    final gForce = magnitude / 9.80665;

    final now = DateTime.now();
    final canTrigger =
        now.difference(_lastShakeAt) > const Duration(milliseconds: 900);

    if (gForce >= shakeThresholdG && canTrigger) {
      _lastShakeAt = now;
      _shakeResetTimer?.cancel();

      state = state.copyWith(
        shakeDetected: true,
        shakeCount: state.shakeCount + 1,
      );

      _shakeResetTimer = Timer(const Duration(milliseconds: 450), () {
        if (!mounted) return;
        state = state.copyWith(shakeDetected: false);
      });
    }
  }

  @override
  void dispose() {
    _shakeResetTimer?.cancel();
    _gyroscopeSub?.cancel();
    _accelerometerSub?.cancel();
    super.dispose();
  }
}
