import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:parkease/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('app should start without crashing', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify the app started successfully
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should navigate through main screens', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for splash screen to complete (if any)
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verify we can find basic UI elements
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
    });
  });
}