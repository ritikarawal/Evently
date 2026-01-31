import 'package:event_planner/features/auth/data/models/auth_api_model.dart';
import 'package:event_planner/features/auth/domain/entities/auth_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthApiModel', () {
    test('fromJson should create model with correct values', () {
      final json = {
        '_id': '1',
        'firstName': 'Ritika',
        'lastName': 'Rawal',
        'email': 'ri@example.com',
        'username': 'ritika',
        'phoneNumber': '9841000000',
        'profilePicture': 'pic.png',
      };

      final model = AuthApiModel.fromJson(json);

      expect(model.id, '1');
      expect(model.fullName, 'Ritika Rawal');
      expect(model.email, 'ri@example.com');
      expect(model.username, 'ritika');
      expect(model.phoneNumber, '9841000000');
      expect(model.profilePicture, 'pic.png');
    });
    test('toJson should split fullName into first and last name', () {
      final model = AuthApiModel(
        fullName: 'User test',
        email: 'user@example.com',
        password: 'password',
      );

      final json = model.toJson();

      expect(json['firstName'], 'User');
      expect(json['lastName'], 'test');
      expect(json['email'], 'user@example.com');
      expect(json['username'], 'user');
      expect(json['confirmPassword'], 'password');
    });
    test('toEntity should convert AuthApiModel to AuthEntity', () {
      final model = AuthApiModel(
        id: '111',
        fullName: 'Testing Test',
        email: 'test@test.com',
        phoneNumber: '9851011111',
        profilePicture: 'profile.jpg',
      );

      final entity = model.toEntity();

      expect(entity, isA<AuthEntity>());
      expect(entity.authId, '111');
      expect(entity.fullName, 'Testing Test');
      expect(entity.email, 'test@test.com');
      expect(entity.phoneNumber, '9851011111');
      expect(entity.profilePicture, 'profile.jpg');
    });
  });
}
