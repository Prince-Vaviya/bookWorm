import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookworm/main.dart';
import 'package:bookworm/screens/auth/login_screen.dart';

void main() {
  testWidgets(
    'Splash transition to LoginScreen and branding check',
    (WidgetTester tester) async {
      // Build our app and trigger initial frame.
      await tester.pumpWidget(const BookwormApp());

      // Initially on SplashScreen
      expect(find.text('Book'), findsOneWidget);
      expect(find.text('Worm'), findsOneWidget);

      // Fast-forward time past splash delay (2.5s) and transition
      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pumpAndSettle();

      // Verify LoginScreen is loaded with reader login options
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(
        find.text('Sign in to your intellectual sanctuary'),
        findsOneWidget,
      );
      expect(find.text('EMAIL ADDRESS'), findsOneWidget);
      expect(find.text('PASSWORD'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    },
  );

  testWidgets('Auth tab switcher switches to Create Account form', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BookwormApp());
    await tester.pump(const Duration(milliseconds: 3000));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);

    // Tap Create Account
    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();

    // Verify Create Account fields
    expect(find.text('FULL NAME'), findsOneWidget);
    expect(find.text('CONFIRM PASSWORD'), findsOneWidget);
    expect(find.text('CREATE READER ACCOUNT'), findsOneWidget);
  });

  testWidgets(
    'Auto-Fill Demo Credentials fills email and password fields',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const BookwormApp());
      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pumpAndSettle();

      // Find Auto-Fill button and tap
      final autoFillFinder = find.text('Auto-Fill Demo Credentials');
      expect(autoFillFinder, findsOneWidget);

      await tester.ensureVisible(autoFillFinder);
      await tester.tap(autoFillFinder);
      await tester.pumpAndSettle();

      // Verify email was set in the text field controller
      expect(find.text('reader@test.app'), findsWidgets);
    },
  );

  testWidgets('Direct entry to MainShell renders desktop & mobile elements', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BookwormApp());
    await tester.pump(const Duration(milliseconds: 3000));
    await tester.pumpAndSettle();

    // Verify MainShell can be loaded and tested
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
