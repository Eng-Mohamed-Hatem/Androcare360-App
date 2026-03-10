import 'dart:async';

import 'package:elajtech/features/admin/presentation/screens/admin_patient_packages_page.dart';
import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/domain/entities/package_service_item.dart';
import 'package:elajtech/features/packages/domain/entities/patient_package_entity.dart';
import 'package:elajtech/features/packages/presentation/providers/admin_patient_packages_provider.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

class MockAdminPatientPackagesNotifier extends AdminPatientPackagesNotifier {
  MockAdminPatientPackagesNotifier(this.fetcher);
  final Future<List<PatientPackageEntity>> Function() fetcher;

  @override
  Future<List<PatientPackageEntity>> build(String arg) => fetcher();

  @override
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(fetcher);
  }
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ar');
  });

  final dummyPatient = UserModel(
    id: 'patient_1',
    fullName: 'Ahmed Ali',
    email: 'ahmed@test.com',
    phoneNumber: '123',
    userType: UserType.patient,
    createdAt: DateTime(2025),
  );

  final dummyPackageActive = PatientPackageEntity(
    id: 'pp_1',
    patientId: 'patient_1',
    packageId: 'pkg_1',
    clinicId: 'andrology',
    category: PackageCategory.andrologyInfertilityProstate,
    status: PatientPackageStatus.active,
    purchaseDate: DateTime(2026, 3),
    expiryDate: DateTime(2026, 4),
    totalServicesCount: 5,
    usedServicesCount: 1,
    servicesUsage: const [
      ServiceUsageItem(
        serviceId: 's1',
        usedCount: 1,
      ),
    ],
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  Widget createSubject(Future<List<PatientPackageEntity>> Function() fetcher) {
    return ProviderScope(
      overrides: [
        adminPatientPackagesProvider.overrideWith(
          () => MockAdminPatientPackagesNotifier(fetcher),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ar')],
        locale: const Locale('ar'),
        home: AdminPatientPackagesPage(patient: dummyPatient),
      ),
    );
  }

  group('AdminPatientPackagesPage Widget Tests', () {
    testWidgets('shows loading state initially', (tester) async {
      final completer = Completer<List<PatientPackageEntity>>();
      await tester.pumpWidget(createSubject(() => completer.future));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state', (tester) async {
      await tester.pumpWidget(createSubject(() async => []));
      await tester.pumpAndSettle();

      expect(find.textContaining('لا توجد'), findsOneWidget);
    });

    testWidgets('shows packages list', (tester) async {
      await tester.pumpWidget(
        createSubject(() async => [dummyPackageActive]),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsAtLeastNWidgets(1));
      expect(find.textContaining('andrology'), findsOneWidget);
    });
  });
}
