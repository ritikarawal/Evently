import 'package:event_planner/features/sensors/presentation/state/motion_sensor_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MotionSensorDebugScreen extends ConsumerStatefulWidget {
  const MotionSensorDebugScreen({super.key});

  @override
  ConsumerState<MotionSensorDebugScreen> createState() =>
      _MotionSensorDebugScreenState();
}

class _MotionSensorDebugScreenState
    extends ConsumerState<MotionSensorDebugScreen> {
  bool _closeAppOnShake = false;
  int _lastHandledShakeCount = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(motionSensorControllerProvider.notifier).startListening(),
    );
  }

  @override
  void dispose() {
    ref.read(motionSensorControllerProvider.notifier).stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(motionSensorControllerProvider);

    _handleShakeSideEffects(state.shakeDetected, state.shakeCount);

    final tiltX = (-state.gyroY).clamp(-1.5, 1.5) / 1.5;
    final tiltY = state.gyroX.clamp(-1.5, 1.5) / 1.5;

    return Scaffold(
      appBar: AppBar(title: const Text('Motion Sensors Debug')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile.adaptive(
            value: _closeAppOnShake,
            onChanged: (value) => setState(() => _closeAppOnShake = value),
            title: const Text('Shake device to close app'),
            subtitle: const Text('Enable only for testing behavior.'),
          ),
          const SizedBox(height: 12),
          _statusCard(
            title: 'Sensor Status',
            values: [
              _line('Listening', state.isListening ? 'yes' : 'no'),
              _line('Tilt Direction', state.tiltDirection),
              _line('Shake Detected', state.shakeDetected ? 'yes' : 'no'),
              _line('Shake Count', state.shakeCount.toString()),
            ],
          ),
          const SizedBox(height: 12),
          _statusCard(
            title: 'Gyroscope (rad/s)',
            values: [
              _line('X', state.gyroX.toStringAsFixed(3)),
              _line('Y', state.gyroY.toStringAsFixed(3)),
              _line('Z', state.gyroZ.toStringAsFixed(3)),
            ],
          ),
          const SizedBox(height: 12),
          _statusCard(
            title: 'Accelerometer (m/s²)',
            values: [
              _line('X', state.accelX.toStringAsFixed(3)),
              _line('Y', state.accelY.toStringAsFixed(3)),
              _line('Z', state.accelZ.toStringAsFixed(3)),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Tilt Interaction Example',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Container(
            height: 190,
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.blueGrey.shade100),
            ),
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 80),
                  alignment: Alignment(tiltX.toDouble(), tiltY.toDouble()),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.gamepad, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final notifier = ref.read(motionSensorControllerProvider.notifier);
          if (state.isListening) {
            notifier.stopListening();
          } else {
            notifier.startListening();
          }
        },
        label: Text(state.isListening ? 'Stop' : 'Start'),
        icon: Icon(state.isListening ? Icons.pause : Icons.play_arrow),
      ),
    );
  }

  void _handleShakeSideEffects(bool shakeDetected, int shakeCount) {
    if (!shakeDetected || shakeCount <= _lastHandledShakeCount) {
      return;
    }

    _lastHandledShakeCount = shakeCount;

    if (_closeAppOnShake) {
      SystemNavigator.pop();
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Shake #$shakeCount detected'),
          duration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  Widget _statusCard({required String title, required List<Widget> values}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...values,
          ],
        ),
      ),
    );
  }

  Widget _line(String axis, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              axis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}
