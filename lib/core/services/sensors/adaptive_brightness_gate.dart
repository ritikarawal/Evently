import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:light/light.dart';
import 'package:screen_brightness/screen_brightness.dart';

class AdaptiveBrightnessGate extends StatefulWidget {
  const AdaptiveBrightnessGate({
    super.key,
    required this.child,
    this.enabled = true,
    this.minBrightness = 0.25,
    this.maxBrightness = 1.0,
  });

  final Widget child;
  final bool enabled;
  final double minBrightness;
  final double maxBrightness;

  @override
  State<AdaptiveBrightnessGate> createState() => _AdaptiveBrightnessGateState();
}

class _AdaptiveBrightnessGateState extends State<AdaptiveBrightnessGate> {
  final Light _light = Light();
  final ScreenBrightness _screenBrightness = ScreenBrightness();

  StreamSubscription<int>? _lightSubscription;
  bool _isApplying = false;
  double? _lastAppliedBrightness;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(covariant AdaptiveBrightnessGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) {
      if (widget.enabled) {
        _start();
      } else {
        _stop(resetBrightness: true);
      }
    }
  }

  void _start() {
    _stop();
    if (!widget.enabled) return;

    _lightSubscription = _light.lightSensorStream.listen(
      (lux) => _applyBrightnessForLux(lux.toDouble()),
      onError: (_) {
        // Ignore unsupported sensor/platform errors to avoid disrupting app flow.
      },
      cancelOnError: false,
    );
  }

  Future<void> _applyBrightnessForLux(double lux) async {
    if (!mounted || _isApplying) return;

    final target = _mapLuxToBrightness(
      lux: lux,
      min: widget.minBrightness,
      max: widget.maxBrightness,
    );

    if (_lastAppliedBrightness != null &&
        (target - _lastAppliedBrightness!).abs() < 0.05) {
      return;
    }

    _isApplying = true;
    try {
      await _screenBrightness.setApplicationScreenBrightness(target);
      _lastAppliedBrightness = target;
    } catch (_) {
      // Best-effort behavior for devices that do not allow app brightness control.
    } finally {
      _isApplying = false;
    }
  }

  double _mapLuxToBrightness({
    required double lux,
    required double min,
    required double max,
  }) {
    final safeLux = lux.clamp(0, 20000).toDouble();
    final normalized = math.log(safeLux + 1) / math.log(20001);
    final value = min + (max - min) * normalized;
    return value.clamp(min, max);
  }

  Future<void> _stop({bool resetBrightness = false}) async {
    await _lightSubscription?.cancel();
    _lightSubscription = null;

    if (resetBrightness) {
      try {
        await _screenBrightness.resetApplicationScreenBrightness();
      } catch (_) {
        // Ignore reset errors on unsupported platforms.
      }
    }
  }

  @override
  void dispose() {
    _stop(resetBrightness: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
