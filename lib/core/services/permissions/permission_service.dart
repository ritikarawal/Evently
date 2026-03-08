import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';

enum AppPermissionType { camera, notifications, sensors }

class AppPermissionResult {
  const AppPermissionResult({
    required this.type,
    required this.status,
    required this.title,
    required this.message,
    this.canOpenSettings = true,
    this.unavailableSensors = const <String>[],
  });

  final AppPermissionType type;
  final PermissionStatus status;
  final String title;
  final String message;
  final bool canOpenSettings;
  final List<String> unavailableSensors;

  bool get isGranted => status.isGranted || status.isLimited;
  bool get isPermanentlyDenied => status.isPermanentlyDenied;
}

class PermissionService {
  PermissionService({DeviceInfoPlugin? deviceInfoPlugin})
    : _deviceInfo = deviceInfoPlugin ?? DeviceInfoPlugin();

  final DeviceInfoPlugin _deviceInfo;

  Future<List<AppPermissionResult>> requestStartupPermissions() async {
    final camera = await requestCameraPermission();
    final notifications = await requestNotificationPermission();
    final sensors = await requestSensorsPermission();

    return <AppPermissionResult>[camera, notifications, sensors];
  }

  Future<AppPermissionResult> requestCameraPermission() async {
    final status = await _requestPermission(Permission.camera);
    return AppPermissionResult(
      type: AppPermissionType.camera,
      status: status,
      title: 'Camera permission required',
      message:
          'Camera access is needed for profile photos and the in-app camera feature.',
    );
  }

  Future<AppPermissionResult> requestNotificationPermission() async {
    final shouldAsk = await _shouldRequestNotificationPermission();
    final status = shouldAsk
        ? await _requestPermission(Permission.notification)
        : PermissionStatus.granted;

    return AppPermissionResult(
      type: AppPermissionType.notifications,
      status: status,
      title: 'Notification permission required',
      message:
          'Notification access helps you receive new message and match alerts instantly.',
    );
  }

  Future<AppPermissionResult> requestSensorsPermission() async {
    PermissionStatus sensorStatus;
    PermissionStatus activityStatus;
    try {
      sensorStatus = await _requestPermission(Permission.sensors);
    } catch (_) {
      sensorStatus = PermissionStatus.granted;
    }

    try {
      activityStatus = await _requestPermission(Permission.activityRecognition);
    } catch (_) {
      activityStatus = PermissionStatus.granted;
    }

    final status = _mergePermissionStatus(sensorStatus, activityStatus);

    final unavailableSensors = await _checkUnavailableSensors();

    // Gyroscope/accelerometer used for shake/tilt do not usually require
    // a dedicated runtime permission that appears in app settings.
    if (unavailableSensors.isNotEmpty) {
      return AppPermissionResult(
        type: AppPermissionType.sensors,
        status: status.isGranted ? PermissionStatus.denied : status,
        title: 'Sensor availability issue',
        message:
            'Some required sensors are not available on this device: ${unavailableSensors.join(', ')}.',
        canOpenSettings: true,
        unavailableSensors: unavailableSensors,
      );
    }

    return AppPermissionResult(
      type: AppPermissionType.sensors,
      status: status,
      title: 'Sensor permission required',
      message:
          'Sensor access is needed for light and motion features (gyroscope, accelerometer).',
      unavailableSensors: unavailableSensors,
    );
  }

  PermissionStatus _mergePermissionStatus(
    PermissionStatus first,
    PermissionStatus second,
  ) {
    if (first.isPermanentlyDenied || second.isPermanentlyDenied) {
      return PermissionStatus.permanentlyDenied;
    }
    if (first.isDenied || second.isDenied) {
      return PermissionStatus.denied;
    }
    if (first.isRestricted || second.isRestricted) {
      return PermissionStatus.restricted;
    }
    if (first.isLimited || second.isLimited) {
      return PermissionStatus.limited;
    }
    return PermissionStatus.granted;
  }

  Future<PermissionStatus> _requestPermission(Permission permission) async {
    final currentStatus = await permission.status;
    if (currentStatus.isGranted || currentStatus.isLimited) {
      return currentStatus;
    }
    return permission.request();
  }

  Future<bool> _shouldRequestNotificationPermission() async {
    if (!Platform.isAndroid) {
      return true;
    }

    final androidInfo = await _deviceInfo.androidInfo;
    return androidInfo.version.sdkInt >= 33;
  }

  Future<List<String>> _checkUnavailableSensors() async {
    final unavailable = <String>[];

    final hasGyroscope = await _canReadStream(
      gyroscopeEventStream(samplingPeriod: SensorInterval.normalInterval),
    );
    if (!hasGyroscope) {
      unavailable.add('gyroscope');
    }

    final hasAccelerometer = await _canReadStream(
      accelerometerEventStream(samplingPeriod: SensorInterval.normalInterval),
    );
    if (!hasAccelerometer) {
      unavailable.add('accelerometer');
    }

    final hasLightSensor = await _canReadLightSensor();
    if (!hasLightSensor) {
      unavailable.add('light sensor');
    }

    return unavailable;
  }

  Future<bool> _canReadStream<T>(Stream<T> stream) async {
    try {
      await stream.first.timeout(const Duration(seconds: 2));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _canReadLightSensor() async {
    // sensors_plus currently provides motion sensors in this project setup.
    // Keep light sensor as a best-effort check without blocking startup.
    return true;
  }
}
