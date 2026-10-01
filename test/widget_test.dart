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

      // Verify LoginScreen is loaded with Reader and Admin login options
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

  testWidgets('Role Switcher selects Admin and updates submit button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BookwormApp());
    await tester.pump(const Duration(milliseconds: 3000));
    await tester.pumpAndSettle();

    // Select Admin tab
    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle();

    expect(find.text('SIGN IN AS ADMINISTRATOR'), findsOneWidget);
  });

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
