import 'package:elajtech/shared/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserModel - JSON Mapping (Specialization & ProfileImage)', () {
    final baseJson = {
      'id': 'user-123',
      'email': 'test@test.com',
      'fullName': 'Test User',
      'userType': 'doctor',
      'createdAt': '2024-01-01T00:00:00.000Z',
      'isActive': true,
    };

    test('parses legacy specialization (String) correctly', () {
      final json = {
        ...baseJson,
        'specialization': 'طب الأطفال',
      };

      final user = UserModel.fromJson(json);

      expect(user.specializations, equals(['طب الأطفال']));
    });

    test('parses legacy specialization (List) correctly', () {
      final json = {
        ...baseJson,
        'specialization': ['طب الأطفال', 'التغذية'],
      };

      final user = UserModel.fromJson(json);

      expect(user.specializations, equals(['طب الأطفال', 'التغذية']));
    });

    test('parses new specializations (List) correctly', () {
      final json = {
        ...baseJson,
        'specializations': ['طب الأطفال', 'التغذية'],
      };

      final user = UserModel.fromJson(json);

      expect(user.specializations, equals(['طب الأطفال', 'التغذية']));
    });

    test('specializations prend precedence over specialization', () {
      final json = {
        ...baseJson,
        'specialization': 'Old Specialty',
        'specializations': ['New Specialty'],
      };

      final user = UserModel.fromJson(json);

      expect(user.specializations, equals(['New Specialty']));
    });

    test('parses profileImage correctly', () {
      final json = {
        ...baseJson,
        'profileImage': 'https://example.com/image.jpg',
      };

      final user = UserModel.fromJson(json);

      expect(user.profileImage, equals('https://example.com/image.jpg'));
    });

    test('toJson uses plural specializations key', () {
      final user = UserModel(
        id: 'user-123',
        email: 'test@test.com',
        fullName: 'Test User',
        userType: UserType.doctor,
        createdAt: DateTime(2024),
        specializations: ['Pediatrics'],
        profileImage: 'https://example.com/image.jpg',
      );

      final json = user.toJson();

      expect(json['specializations'], equals(['Pediatrics']));
      expect(json.containsKey('specialization'), isFalse);
      expect(json['profileImage'], equals('https://example.com/image.jpg'));
    });
  });
}
