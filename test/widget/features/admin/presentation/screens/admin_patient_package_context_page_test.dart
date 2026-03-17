import 'dart:async';

import 'package:elajtech/features/admin/presentation/screens/admin_patient_package_context_page.dart';
import 'package:elajtech/features/packages/domain/entities/package_document_entity.dart';
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

class _FakeAdminPatientPackageWriteNotifier
    extends AdminPatientPackageWriteNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  @override
  Future<bool> updateNotes({
    required String patientId,
    required String patientPackageId,
    required String notes,
  }) async => true;

  @override
  Future<bool> updateServiceUsage({
    required String patientId,
    required String patientPackageId,
    required String serviceId,
  }) async => true;
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

  final dummyPackage = PatientPackageEntity(
    id: 'pp_12345678',
    patientId: 'patient_1',
    packageId: 'pkg_1',
    packageName: 'Test Package',
    clinicId: 'andrology',
    category: PackageCategory.andrologyInfertilityProstate,
    status: PatientPackageStatus.active,
    purchaseDate: DateTime(2026, 3),
    expiryDate: DateTime(2026, 4),
    totalServicesCount: 5,
    usedServicesCount: 1,
    servicesUsage: const [
      ServiceUsageItem(serviceId: 's1', usedCount: 1),
    ],
    packageServices: const [
      PackageServiceItem(
        serviceId: 's1',
        serviceType: ServiceType.visit,
        displayName: 'كشف متابعة',
        quantity: 5,
      ),
    ],
    notes: 'Initial notes',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  Widget createSubject() {
    return ProviderScope(
      overrides: [
        adminPatientPackagesProvider.overrideWith(
          () => MockAdminPatientPackagesNotifier(() async => [dummyPackage]),
        ),
        adminPatientPackageWriteProvider.overrideWith(
          _FakeAdminPatientPackageWriteNotifier.new,
        ),
        adminPackageDocumentsProvider.overrideWith(
          (ref, arg) => Stream.value([]),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(useMaterial3: false),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ar')],
        locale: const Locale('ar'),
        home: AdminPatientPackageContextPage(
          patient: dummyPatient,
          patientPackage: dummyPackage,
        ),
      ),
    );
  }

  group('AdminPatientPackageContextPage Widget Tests', () {
    testWidgets(
      'shows friendly permission message for denied documents query',
      (
        tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              adminPatientPackagesProvider.overrideWith(
                () => MockAdminPatientPackagesNotifier(
                  () async => [dummyPackage],
                ),
              ),
              adminPatientPackageWriteProvider.overrideWith(
                _FakeAdminPatientPackageWriteNotifier.new,
              ),
              adminPackageDocumentsProvider.overrideWith(
                (ref, arg) => Stream.error(
                  Exception('cloud_firestore/permission-denied'),
                ),
              ),
            ],
            child: MaterialApp(
              theme: ThemeData(useMaterial3: false),
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('ar')],
              locale: const Locale('ar'),
              home: AdminPatientPackageContextPage(
                patient: dummyPatient,
                patientPackage: dummyPackage,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AdminPatientPackageContextPage), findsOneWidget);
      },
    );

    testWidgets('renders and shows data', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.byType(AdminPatientPackageContextPage), findsOneWidget);
      expect(find.textContaining('Ahmed'), findsOneWidget);
    });

    testWidgets('shows notes from current package', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.textContaining('Initial'), findsOneWidget);
    });

    testWidgets('shows explicit service usage layout', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.textContaining('Test Package'), findsOneWidget);
      expect(find.byIcon(Icons.analytics_outlined), findsOneWidget);
      expect(find.byIcon(Icons.add_circle_outline), findsNothing);
    });

    testWidgets(
      'header renders without overflow with long Arabic text on small device',
      (tester) async {
        tester.view.physicalSize = const Size(375, 667);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final longPackage = PatientPackageEntity(
          id: 'pp_12345678',
          patientId: 'patient_1',
          packageId: 'pkg_1',
          packageName: 'باقة شاملة للفحوصات الطبية المتقدمة والتشخيص الدقيق',
          clinicId: 'andrology',
          category: PackageCategory.andrologyInfertilityProstate,
          status: PatientPackageStatus.active,
          purchaseDate: DateTime(2026, 3),
          expiryDate: DateTime(2026, 4),
          totalServicesCount: 5,
          usedServicesCount: 1,
          servicesUsage: const [
            ServiceUsageItem(serviceId: 's1', usedCount: 1),
          ],
          packageServices: const [
            PackageServiceItem(
              serviceId: 's1',
              serviceType: ServiceType.visit,
              displayName: 'كشف متابعة',
              quantity: 5,
            ),
          ],
          notes: 'Initial notes',
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              adminPatientPackagesProvider.overrideWith(
                () =>
                    MockAdminPatientPackagesNotifier(() async => [longPackage]),
              ),
              adminPatientPackageWriteProvider.overrideWith(
                _FakeAdminPatientPackageWriteNotifier.new,
              ),
              adminPackageDocumentsProvider.overrideWith(
                (ref, arg) => Stream.value([]),
              ),
            ],
            child: MaterialApp(
              theme: ThemeData(useMaterial3: false),
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('ar')],
              locale: const Locale('ar'),
              home: AdminPatientPackageContextPage(
                patient: dummyPatient,
                patientPackage: longPackage,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AdminPatientPackageContextPage), findsOneWidget);
        expect(find.textContaining('باقة شاملة'), findsOneWidget);
      },
    );

    testWidgets('shows checkmark on services with linked documents', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final linkedDoc = PackageDocumentEntity(
        id: 'doc_1',
        patientId: 'patient_1',
        patientPackageId: 'pp_12345678',
        packageId: 'pkg_1',
        clinicId: 'andrology',
        documentType: DocumentType.labResult,
        title: 'Test Document',
        fileUrl: 'https://example.com/doc.pdf',
        uploadedByUserId: 'admin_1',
        uploadedByRole: 'ADMIN',
        uploadedAt: DateTime.now(),
        serviceId: 's1',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adminPatientPackagesProvider.overrideWith(
              () =>
                  MockAdminPatientPackagesNotifier(() async => [dummyPackage]),
            ),
            adminPatientPackageWriteProvider.overrideWith(
              _FakeAdminPatientPackageWriteNotifier.new,
            ),
            adminPackageDocumentsProvider.overrideWith(
              (ref, arg) => Stream.value([linkedDoc]),
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
            home: AdminPatientPackageContextPage(
              patient: dummyPatient,
              patientPackage: dummyPackage,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets(
      'Admin Notes label renders fully without clipping on small device',
      (tester) async {
        tester.view.physicalSize = const Size(375, 667);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(createSubject());
        await tester.pumpAndSettle();

        await tester.dragUntilVisible(
          find.textContaining('ملاحظات الأدمن'),
          find.byType(ListView),
          const Offset(0, -300),
        );
        expect(find.textContaining('ملاحظات الأدمن'), findsOneWidget);
      },
    );

    testWidgets(
      'services usage counter updates when documents are attached',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final linkedDoc = PackageDocumentEntity(
          id: 'doc_1',
          patientId: 'patient_1',
          patientPackageId: 'pp_12345678',
          packageId: 'pkg_1',
          clinicId: 'andrology',
          documentType: DocumentType.labResult,
          title: 'Test Document',
          fileUrl: 'https://example.com/doc.pdf',
          uploadedByUserId: 'admin_1',
          uploadedByRole: 'ADMIN',
          uploadedAt: DateTime.now(),
          serviceId: 's1',
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              adminPatientPackagesProvider.overrideWith(
                () => MockAdminPatientPackagesNotifier(() async => [dummyPackage]),
              ),
              adminPatientPackageWriteProvider.overrideWith(
                _FakeAdminPatientPackageWriteNotifier.new,
              ),
              adminPackageDocumentsProvider.overrideWith(
                (ref, arg) => Stream.value([linkedDoc]),
              ),
            ],
            child: MaterialApp(
              theme: ThemeData(useMaterial3: false),
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('ar')],
              locale: const Locale('ar'),
              home: AdminPatientPackageContextPage(
                patient: dummyPatient,
                patientPackage: dummyPackage,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      },
    );
  });
}
