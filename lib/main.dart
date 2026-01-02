import 'package:event_planner/app.dart';
import 'package:event_planner/core/services/hive/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/storage/user_session_service.dart';

late final ProviderContainer _container;

Future<void> _initializeServices() async {
  // Initialize Hive Database
  final hiveService = HiveService();
  await hiveService.init();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Create container with initialized dependencies
  _container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(sharedPreferences)],
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeServices();
  runApp(UncontrolledProviderScope(container: _container, child: const App()));
}
