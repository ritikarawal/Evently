import 'dart:io';
import 'package:event_planner/core/services/hive/hive_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:event_planner/core/constants/hive_table_constant.dart';
import 'package:event_planner/features/auth/data/models/auth_hive_model.dart';

void main() {
  late HiveService hiveService;
  late String testPath;

  setUp(() async {
    // isolated Hive storage
    testPath = Directory.systemTemp.createTempSync().path;
    Hive.init(testPath);

    if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
    hiveService = HiveService();
  });
  tearDown(() async {
    await Hive.close();
    Directory(testPath).deleteSync(recursive: true);
  });

  test('should save user to hive and retrieve it by id', () async {
    final user = AuthHiveModel(
      authId: '1',
      fullName: 'Test User',
      username: 'testuser',
      email: 'test@example.com',
      password: '123456',
    );

    await hiveService.register(user);
    final result = hiveService.getUserById('1');

    expect(result, isNotNull);
    expect(result!.authId, '1');
    expect(result.email, 'test@example.com');
    expect(result.fullName, 'Test User');
  });
  test('login returns null when email or password is incorrect', () async {
    final user = AuthHiveModel(
      authId: '2',
      fullName: 'You You',
      username: 'youyou',
      email: 'you@test.com',
      password: 'password',
    );

    await hiveService.register(user);
    final result = hiveService.login('you@test.com', 'wrongpassword');
    expect(result, isNull);
  });
}
