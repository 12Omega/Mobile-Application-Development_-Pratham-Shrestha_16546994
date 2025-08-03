import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class TestHelpers {
  /// Creates a MaterialApp wrapper for testing widgets
  static Widget createTestApp({
    required Widget child,
    List<ChangeNotifierProvider>? providers,
    ThemeData? theme,
  }) {
    Widget app = MaterialApp(
      home: child,
      theme: theme ?? ThemeData.light(),
    );

    if (providers != null && providers.isNotEmpty) {
      app = MultiProvider(
        providers: providers,
        child: app,
      );
    }

    return app;
  }

  /// Pumps a widget and waits for all animations to complete
  static Future<void> pumpAndSettle(WidgetTester tester, Widget widget) async {
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();
  }

  /// Sets up a larger test surface for better testing
  static void setupLargeTestSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
  }

  /// Resets the test surface to default
  static void resetTestSurface(WidgetTester tester) {
    tester.view.resetPhysicalSize();
  }

  /// Finds a widget by its text content
  static Finder findByText(String text) {
    return find.text(text);
  }

  /// Finds a widget by its type
  static Finder findByType<T extends Widget>() {
    return find.byType(T);
  }

  /// Taps a widget and waits for the action to complete
  static Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// Enters text in a field and waits for the action to complete
  static Future<void> enterTextAndSettle(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }

  /// Scrolls to find a widget
  static Future<void> scrollToFind(
    WidgetTester tester,
    Finder scrollable,
    Finder target,
  ) async {
    await tester.scrollUntilVisible(target, 100.0, scrollable: scrollable);
    await tester.pumpAndSettle();
  }
}