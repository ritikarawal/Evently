import 'package:event_planner/core/services/permissions/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionStartupGate extends StatefulWidget {
  const PermissionStartupGate({super.key, required this.child});

  final Widget child;

  @override
  State<PermissionStartupGate> createState() => _PermissionStartupGateState();
}

class _PermissionStartupGateState extends State<PermissionStartupGate> {
  final PermissionService _permissionService = PermissionService();
  bool _didRunStartupCheck = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didRunStartupCheck) return;
    _didRunStartupCheck = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissionsOnStartup();
    });
  }

  Future<void> _checkPermissionsOnStartup() async {
    final results = await _permissionService.requestStartupPermissions();
    if (!mounted) return;

    for (final result in results) {
      if (result.isGranted) continue;

      await _showPermissionDialog(result);
      if (!mounted) return;
    }
  }

  Future<void> _showPermissionDialog(AppPermissionResult result) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(result.title),
          content: Text(result.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Not now'),
            ),
            if (result.canOpenSettings)
              ElevatedButton(
                onPressed: () async {
                  await openAppSettings();
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                },
                child: const Text('Open Settings'),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
