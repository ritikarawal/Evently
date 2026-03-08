import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shake/shake.dart';

class ShakeToCloseGate extends StatefulWidget {
  const ShakeToCloseGate({
    super.key,
    required this.child,
    this.enabled = true,
    this.showDebugFeedback = true,
    this.closeDelay = const Duration(milliseconds: 500),
    this.shakeThresholdG = 1.2,
    this.hitsRequired = 2,
    this.hitWindow = const Duration(milliseconds: 650),
    this.shakeCooldown = const Duration(milliseconds: 900),
  });

  final Widget child;
  final bool enabled;
  final bool showDebugFeedback;
  final Duration closeDelay;
  final double shakeThresholdG;
  final int hitsRequired;
  final Duration hitWindow;
  final Duration shakeCooldown;

  @override
  State<ShakeToCloseGate> createState() => _ShakeToCloseGateState();
}

class _ShakeToCloseGateState extends State<ShakeToCloseGate> {
  ShakeDetector? _shakeDetector;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void didUpdateWidget(covariant ShakeToCloseGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) {
      if (widget.enabled) {
        _startListening();
      } else {
        _stopListening();
      }
    }
  }

  void _startListening() {
    _stopListening();
    if (!widget.enabled) return;

    _shakeDetector = ShakeDetector.autoStart(
      shakeThresholdGravity: widget.shakeThresholdG,
      minimumShakeCount: widget.hitsRequired,
      shakeSlopTimeMS: widget.hitWindow.inMilliseconds,
      shakeCountResetTime: widget.shakeCooldown.inMilliseconds,
      onPhoneShake: (_) {
        if (widget.showDebugFeedback) {
          final messenger = ScaffoldMessenger.maybeOf(context);
          messenger?.hideCurrentSnackBar();
          messenger?.showSnackBar(
            const SnackBar(
              content: Text('Shake detected. Closing app...'),
              duration: Duration(milliseconds: 450),
            ),
          );

          Future<void>.delayed(widget.closeDelay, () {
            if (!mounted) return;
            SystemNavigator.pop();
          });
          return;
        }

        SystemNavigator.pop();
      },
    );
  }

  void _stopListening() {
    _shakeDetector?.stopListening();
    _shakeDetector = null;
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
