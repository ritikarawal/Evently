import 'package:event_planner/features/auth/data/models/auth_api_model.dart';
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
  });
}
