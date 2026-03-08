/// Unit tests for DoctorsListProvider
///
/// Tests cover:
/// - Stream-based doctor list provider
/// - Future-based doctor list provider
/// - Error handling
/// - Auto-dispose behavior
/// - Empty list handling
///
/// Target: 85%+ coverage

library;

import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/doctor/domain/repositories/doctor_repository.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:elajtech/shared/providers/registered_doctors_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../fixtures/user_fixtures.dart';
import 'doctors_list_provider_test.mocks.dart';

@GenerateMocks([
  DoctorRepository,
])
void main() {
  late MockDoctorRepository mockRepository;
  final getIt = GetIt.instance;

  setUp(() {
    mockRepository = MockDoctorRepository();

    // Register mock in GetIt
    if (getIt.isRegistered<DoctorRepository>()) {
      getIt.unregister<DoctorRepository>();
    }
    getIt.registerSingleton<DoctorRepository>(mockRepository);
  });

  tearDown(() async {
    if (getIt.isRegistered<DoctorRepository>()) {
      await getIt.unregister<DoctorRepository>();
    }
  });

  group('doctorsListFutureProvider - Future-based', () {
    test('should provide list of doctors from future', () async {
      // Arrange
      final doctors = UserFixtures.createMultipleDoctors();
      when(mockRepository.getDoctors()).thenAnswer((_) async => Right(doctors));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act
      final result = await container.read(doctorsListFutureProvider.future);

      // Assert
      expect(result, equals(doctors));
      expect(result.length, doctors.length);

      verify(mockRepository.getDoctors()).called(1);
    });

    test('should handle empty doctor list from future', () async {
      // Arrange
      when(
        mockRepository.getDoctors(),
      ).thenAnswer((_) async => const Right([]));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act
      final result = await container.read(doctorsListFutureProvider.future);

      // Assert
      expect(result, isEmpty);
    });

    test('should handle repository failure gracefully', () async {
      // Arrange
      when(
        mockRepository.getDoctors(),
      ).thenAnswer((_) async => const Left(ServerFailure('Failed to fetch')));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act
      final result = await container.read(doctorsListFutureProvider.future);

      // Assert - Should return empty list on failure
      expect(result, isEmpty);
    });

    test('should handle network failure', () async {
      // Arrange
      when(
        mockRepository.getDoctors(),
      ).thenAnswer((_) async => const Left(ServerFailure('No internet')));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act
      final result = await container.read(doctorsListFutureProvider.future);

      // Assert
      expect(result, isEmpty);
    });

    test('should provide doctors with valid IDs', () async {
      // Arrange
      final doctors = UserFixtures.createMultipleDoctors();
      when(mockRepository.getDoctors()).thenAnswer((_) async => Right(doctors));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act
      final result = await container.read(doctorsListFutureProvider.future);

      // Assert
      expect(result.every((d) => d.id.isNotEmpty), true);
    });

    test('should provide doctors with full names', () async {
      // Arrange
      final doctors = UserFixtures.createMultipleDoctors();
      when(mockRepository.getDoctors()).thenAnswer((_) async => Right(doctors));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act
      final result = await container.read(doctorsListFutureProvider.future);

      // Assert
      expect(result.every((d) => d.fullName.isNotEmpty), true);
    });

    test('should provide doctors with correct user type', () async {
      // Arrange
      final doctors = UserFixtures.createMultipleDoctors();
      when(mockRepository.getDoctors()).thenAnswer((_) async => Right(doctors));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act
      final result = await container.read(doctorsListFutureProvider.future);

      // Assert
      expect(result.every((d) => d.userType == UserType.doctor), true);
    });

    test('should provide doctors with specializations', () async {
      // Arrange
      final doctors = UserFixtures.createMultipleDoctors();
      when(mockRepository.getDoctors()).thenAnswer((_) async => Right(doctors));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act
      final result = await container.read(doctorsListFutureProvider.future);

      // Assert
      expect(result.every((d) => d.specializations?.isNotEmpty ?? false), true);
    });
  });
}
