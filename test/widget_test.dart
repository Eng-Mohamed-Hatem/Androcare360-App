// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are pretty close.

import 'package:elajtech/features/auth/presentation/screens/login_screen.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthNotifier extends StateNotifier<AuthState>
    implements AuthNotifier {
  _FakeAuthNotifier() : super(AuthState());

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  testWidgets('App starts and shows LoginScreen', (WidgetTester tester) async {
    // Build a minimal app with just the LoginScreen.
    // Override authProvider so GetIt and Firebase are not needed.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => _FakeAuthNotifier()),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Verify that the login screen is displayed
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
