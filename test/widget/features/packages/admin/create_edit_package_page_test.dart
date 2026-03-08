import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/domain/entities/package_service_item.dart';
import 'package:elajtech/features/packages/domain/usecases/create_clinic_package_usecase.dart';
import 'package:elajtech/features/packages/presentation/pages/create_edit_package_page.dart';
import 'package:elajtech/features/packages/presentation/providers/admin_packages_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class MockAdminPackageWriteNotifier extends AdminPackageWriteNotifier {
  @override
  Future<bool> createPackage(CreatePackageParams params) async {
    return true;
  }
}

void main() {
  final dummyPackageActive = PackageEntity(
    id: 'pkg1',
    clinicId: 'andrology',
    category: PackageCategory.andrologyInfertilityProstate,
    name: 'باقة نشطة',
    shortDescription: 'وصف',
    services: const [
      PackageServiceItem(
        serviceId: 's1',
        serviceType: ServiceType.visit,
        displayName: 'كشف',
      ),
    ],
    validityDays: 30,
    price: 1500,
    currency: 'EGP',
    packageType: PackageType.both,
    status: PackageStatus.active,
    displayOrder: 1,
    isFeatured: true,
    createdAt: DateTime(2025),
    updatedAt: DateTime(2025),
    includesVideoConsultation: true,
    includesPhysicalVisit: true,
  );

  Widget createSubject([PackageEntity? package]) {
    return ProviderScope(
      overrides: [
        adminSelectedClinicProvider.overrideWith((ref) => 'andrology'),
        adminPackageWriteProvider.overrideWith(
          MockAdminPackageWriteNotifier.new,
        ),
      ],
      child: MaterialApp(
        home: CreateEditPackagePage(packageToEdit: package),
      ),
    );
  }

  group('CreateEditPackagePage Widget Tests', () {
    testWidgets('empty name shows validation error', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('إنشاء الباقة'));
      await tester.tap(find.text('إنشاء الباقة'));
      await tester.pumpAndSettle();

      expect(find.text('هذا الحقل مطلوب'), findsWidgets); // For name and price
    });

    testWidgets('empty services shows validation error snackbar', (
      tester,
    ) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Delete the default service
      await tester.dragUntilVisible(
        find.byIcon(Icons.delete),
        find.byType(SingleChildScrollView),
        const Offset(0, -500),
      );
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Fill required fields
      await tester.enterText(
        find.widgetWithText(TextFormField, 'اسم الباقة *'),
        'باقة تست',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'وصف مختصر *'),
        'وصف تست',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'السعر (EGP) *'),
        '1000',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'الصلاحية (بالأيام) *'),
        '30',
      );

      await tester.ensureVisible(find.text('إنشاء الباقة'));
      await tester.tap(find.text('إنشاء الباقة'));
      await tester.pumpAndSettle();

      // Snackbar should appear
      expect(find.text('الرجاء إضافة خدمة واحدة على الأقل'), findsOneWidget);
    });

    testWidgets('empty service display name shows error snackbar', (
      tester,
    ) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Fill required fields
      await tester.enterText(
        find.widgetWithText(TextFormField, 'اسم الباقة *'),
        'باقة تست',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'وصف مختصر *'),
        'وصف تست',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'السعر (EGP) *'),
        '1000',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'الصلاحية (بالأيام) *'),
        '30',
      );
      // Service name is left empty by default

      await tester.ensureVisible(find.text('إنشاء الباقة'));
      await tester.tap(find.text('إنشاء الباقة'));
      await tester.pumpAndSettle();

      // Snackbar
      expect(
        find.text('الرجاء إدخال أسماء جميع الخدمات بشكل صحيح'),
        findsOneWidget,
      );
    });

    testWidgets('happy path creation (mock form)', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Fill essential text fields
      await tester.enterText(
        find.widgetWithText(TextFormField, 'اسم الباقة *'),
        'باقة تست',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'وصف مختصر *'),
        'وصف تست',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'السعر (EGP) *'),
        '1000',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'الصلاحية (بالأيام) *'),
        '30',
      );

      // Fill the service name
      await tester.enterText(
        find.widgetWithText(TextFormField, 'الاسم (عربي)'),
        'كشف طبي',
      );

      await tester.ensureVisible(find.text('إنشاء الباقة'));
      await tester.tap(find.text('إنشاء الباقة'));
      await tester.pump();

      // We don't verify full navigation/write success because we didn't mock the notifier state,
      // but the fact it passes the validation confirms UI mechanics.
      expect(find.text('هذا الحقل مطلوب'), findsNothing);
    });

    testWidgets('load package in edit mode', (tester) async {
      await tester.pumpWidget(createSubject(dummyPackageActive));
      await tester.pumpAndSettle();

      // Check fields are pre-filled
      expect(find.text('باقة نشطة'), findsOneWidget);
      expect(
        find.text('1500.0'),
        findsOneWidget,
      ); // Price might be formatted as 1500.0
      expect(find.text('حفظ التغييرات'), findsOneWidget);
    });
  });
}
