class MotionSensorState {
  const MotionSensorState({
    this.isListening = false,
    this.gyroX = 0,
    this.gyroY = 0,
    this.gyroZ = 0,
    this.accelX = 0,
    this.accelY = 0,
    this.accelZ = 0,
    this.shakeDetected = false,
    this.shakeCount = 0,
    this.tiltDirection = 'stable',
  });

  final bool isListening;
  final double gyroX;
  final double gyroY;
  final double gyroZ;
  final double accelX;
  final double accelY;
  final double accelZ;
  final bool shakeDetected;
  final int shakeCount;
  final String tiltDirection;

  MotionSensorState copyWith({
    bool? isListening,
    double? gyroX,
    double? gyroY,
    double? gyroZ,
    double? accelX,
    double? accelY,
    double? accelZ,
    bool? shakeDetected,
    int? shakeCount,
    String? tiltDirection,
  }) {
    return MotionSensorState(
      isListening: isListening ?? this.isListening,
      gyroX: gyroX ?? this.gyroX,
      gyroY: gyroY ?? this.gyroY,
      gyroZ: gyroZ ?? this.gyroZ,
      accelX: accelX ?? this.accelX,
      accelY: accelY ?? this.accelY,
      accelZ: accelZ ?? this.accelZ,
      shakeDetected: shakeDetected ?? this.shakeDetected,
      shakeCount: shakeCount ?? this.shakeCount,
      tiltDirection: tiltDirection ?? this.tiltDirection,
    );
  }
}
