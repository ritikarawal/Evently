import 'package:event_planner/features/auth/domain/entities/auth_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AuthEntity equality is value-based', () {
    const a = AuthEntity(
      authId: '1',
      fullName: 'John Doe',
      email: 'john@example.com',
      phoneNumber: '12345',
      username: 'john',
      password: 'pw',
      profilePicture: 'pic.jpg',
    );
    const b = AuthEntity(
      authId: '1',
      fullName: 'John Doe',
      email: 'john@example.com',
      phoneNumber: '12345',
      username: 'john',
      password: 'pw',
      profilePicture: 'pic.jpg',
    );

    expect(a, b);
  });
}
