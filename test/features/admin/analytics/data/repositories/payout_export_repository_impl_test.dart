import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:elajtech/features/admin/analytics/data/repositories/payout_export_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import '../../analytics_test_helpers.dart';
import 'payout_export_repository_impl_test.mocks.dart';

@GenerateMocks([FirebaseFunctions])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('generates PDF file from payout report', () async {
    final repository = PayoutExportRepositoryImpl(MockFirebaseFunctions());

    final result = await repository.generatePdf(testPayoutReport());

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('expected PDF path'),
      (path) {
        expect(path.endsWith('.pdf'), isTrue);
        expect(File(path).existsSync(), isTrue);
      },
    );
  });

  test('generates Excel file from payout report', () async {
    final repository = PayoutExportRepositoryImpl(MockFirebaseFunctions());

    final result = await repository.generateExcel(testPayoutReport());

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('expected Excel path'),
      (path) {
        expect(path.endsWith('.xlsx'), isTrue);
        expect(File(path).existsSync(), isTrue);
      },
    );
  });
}
