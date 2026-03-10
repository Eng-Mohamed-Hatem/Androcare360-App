import 'package:elajtech/core/constants/currency_constants.dart';
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
    currency: CurrencyConstants.defaultCurrency,
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

      expect(
        find.text('هذا الحقل مطلوب'),
        findsAtLeast(2),
      ); // For name and price
    });

    testWidgets('empty services shows validation error snackbar', (
      tester,
    ) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Delete the default service
      await tester.dragUntilVisible(
        find.byIcon(Icons.delete_outline),
        find.byType(SingleChildScrollView),
        const Offset(0, -500),
      );
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Fill required fields
      await tester.enterText(
        find.widgetWithText(TextFormField, 'اسم الباقة *'),
        'باقة تست',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'وصف مختصر تسويقي *'),
        'وصف تست',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'السعر (ريال سعودي) *'),
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
        find.widgetWithText(TextFormField, 'وصف مختصر تسويقي *'),
        'وصف تست',
      );

      await tester.dragUntilVisible(
        find.widgetWithText(TextFormField, 'السعر (ريال سعودي) *'),
        find.byType(SingleChildScrollView),
        const Offset(0, -500),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'السعر (ريال سعودي) *'),
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

      // Should show red field error instead of snackbar due to form validation
      expect(
        find.text('الرجاء إدخال اسم الخدمة'),
        findsOneWidget,
      );
    });

    testWidgets('happy path creation shows success snackbar', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Fill required fields
      await tester.enterText(
        find.widgetWithText(TextFormField, 'اسم الباقة *'),
        'باقة نجاح',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'وصف مختصر تسويقي *'),
        'وصف تست',
      );

      await tester.dragUntilVisible(
        find.widgetWithText(TextFormField, 'السعر (ريال سعودي) *'),
        find.byType(SingleChildScrollView),
        const Offset(0, -500),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'السعر (ريال سعودي) *'),
        '1000',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'الصلاحية (بالأيام) *'),
        '30',
      );

      // Fill the service name
      await tester.enterText(
        find.widgetWithText(TextFormField, 'اسم الخدمة (عربي)'),
        'كشف طبي',
      );

      await tester.ensureVisible(find.text('إنشاء الباقة'));
      await tester.tap(find.text('إنشاء الباقة'));
      await tester.pump(); // Start creation work
      await tester.pump(); // Trigger feedback logic

      expect(find.text('تم إنشاء الباقة بنجاح'), findsOneWidget);
    });

    testWidgets('creation failure shows error snackbar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adminSelectedClinicProvider.overrideWith((ref) => 'andrology'),
            adminPackageWriteProvider.overrideWith(
              _FailingAdminPackageWriteNotifier.new,
            ),
          ],
          child: const MaterialApp(
            home: CreateEditPackagePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Fill essential text fields
      await tester.enterText(
        find.widgetWithText(TextFormField, 'اسم الباقة *'),
        'باقة فشل',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'وصف مختصر تسويقي *'),
        'وصف',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'السعر (ريال سعودي) *'),
        '1000',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'الصلاحية (بالأيام) *'),
        '30',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'اسم الخدمة (عربي)'),
        'خدمة',
      );

      await tester.ensureVisible(find.text('إنشاء الباقة'));
      await tester.tap(find.text('إنشاء الباقة'));
      await tester.pump(); // Start async work
      await tester.pump(); // Trigger feedback logic

      expect(find.textContaining('فشل الإنشاء'), findsOneWidget);
    });

    testWidgets('load package in edit mode', (tester) async {
      await tester.pumpWidget(createSubject(dummyPackageActive));
      await tester.pumpAndSettle();

      // Check fields are pre-filled
      expect(find.text('باقة نشطة'), findsOneWidget);
      expect(find.textContaining('1500'), findsOneWidget);
      expect(find.text('حفظ التغييرات'), findsOneWidget);
    });
  });
}

class _FailingAdminPackageWriteNotifier extends AdminPackageWriteNotifier {
  @override
  AsyncValue<void> build() => const AsyncError('خطأ تجريبي', StackTrace.empty);

  @override
  Future<bool> createPackage(CreatePackageParams params) async {
    return false;
  }
}
