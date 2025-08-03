import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:parkease/ui/screens/profile/profile_screen_fixed.dart';

void main() {
  group('ProfileScreenFixed Tests', () {
    late GoRouter router;

    setUp(() {
      router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const ProfileScreenFixed(),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Login Screen')),
            ),
          ),
        ],
      );
    });

    // Helper method to create a test widget with larger surface
    Widget createTestWidget() {
      return MaterialApp.router(
        routerConfig: router,
      );
    }

    // Helper method to setup larger test surface
    void setupLargeTestSurface(WidgetTester tester) {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
    }

    testWidgets('should display profile screen with all sections',
        (WidgetTester tester) async {
      setupLargeTestSurface(tester);
      await tester.pumpWidget(createTestWidget());

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Verify the app bar is displayed
      expect(find.text('Profile'), findsOneWidget);

      // Verify main sections are displayed
      expect(find.text('Profile Information'), findsOneWidget);
      expect(find.text('Vehicle Information'), findsOneWidget);
      expect(find.text('Payment Methods'), findsOneWidget);
      expect(find.text('Notification Settings'), findsOneWidget);
      expect(find.text('Help & Support'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);

      // Verify logout button is displayed
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('should display user profile header',
        (WidgetTester tester) async {
      setupLargeTestSurface(tester);
      await tester.pumpWidget(createTestWidget());

      await tester.pumpAndSettle();

      // Verify user profile header elements (allow multiple instances)
      expect(find.text('John Doe'), findsWidgets);
      expect(find.text('john.doe@example.com'),
          findsWidgets); // Allow multiple instances
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsAtLeastNWidgets(1));
    });

    testWidgets('should display profile information section',
        (WidgetTester tester) async {
      setupLargeTestSurface(tester);
      await tester.pumpWidget(createTestWidget());

      await tester.pumpAndSettle();

      // Verify profile information items
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('+1 234 567 8900'), findsOneWidget);
    });

    testWidgets('should display vehicle information section',
        (WidgetTester tester) async {
      setupLargeTestSurface(tester);
      await tester.pumpWidget(createTestWidget());

      await tester.pumpAndSettle();

      // Verify vehicle information
      expect(find.text('Vehicle Details'), findsOneWidget);
      expect(find.text('Toyota Camry - ABC 123'), findsOneWidget);
      expect(find.text('Add Another Vehicle'), findsOneWidget);
    });

    testWidgets('should display notification settings',
        (WidgetTester tester) async {
      setupLargeTestSurface(tester);
      await tester.pumpWidget(createTestWidget());

      await tester.pumpAndSettle();

      // Verify notification settings
      expect(find.text('Enable All Notifications'), findsOneWidget);
      expect(find.text('Parking Updates'), findsOneWidget);
      expect(find.text('Booking Reminders'), findsOneWidget);
      expect(find.text('Promotional Offers'), findsOneWidget);

      // Verify switch tiles
      expect(find.byType(SwitchListTile), findsAtLeastNWidgets(4));
    });

    testWidgets('should open edit profile dialog when edit button is tapped',
        (WidgetTester tester) async {
      setupLargeTestSurface(tester);
      await tester.pumpWidget(createTestWidget());

      await tester.pumpAndSettle();

      // Find and tap the edit button in the profile header
      final editButtons = find.byIcon(Icons.edit);
      await tester.tap(editButtons.first);
      await tester.pumpAndSettle();

      // Verify edit profile dialog is displayed
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('CANCEL'), findsOneWidget);
      expect(find.text('SAVE'), findsOneWidget);
    });

    testWidgets('should toggle notification settings',
        (WidgetTester tester) async {
      setupLargeTestSurface(tester);
      await tester.pumpWidget(createTestWidget());

      await tester.pumpAndSettle();

      // Find the main notification toggle
      final mainToggle = find.byType(SwitchListTile).first;

      // Get initial state
      final SwitchListTile initialSwitch = tester.widget(mainToggle);
      final bool initialValue = initialSwitch.value;

      // Tap to toggle
      await tester.tap(mainToggle);
      await tester.pumpAndSettle();

      // Verify state changed
      final SwitchListTile updatedSwitch = tester.widget(mainToggle);
      expect(updatedSwitch.value, !initialValue);
    });

    testWidgets('should show FAQs dialog when FAQ is tapped',
        (WidgetTester tester) async {
      setupLargeTestSurface(tester);
      await tester.pumpWidget(createTestWidget());

      await tester.pumpAndSettle();

      // Find and tap FAQs
      await tester.tap(find.text('FAQs'));
      await tester.pumpAndSettle();

      // Verify FAQ dialog is displayed
      expect(find.text('Frequently Asked Questions'), findsOneWidget);
      expect(find.text('How do I book a parking spot?'), findsOneWidget);
      expect(find.text('CLOSE'), findsOneWidget);
    });

    testWidgets('should show contact support dialog',
        (WidgetTester tester) async {
      setupLargeTestSurface(tester);
      await tester.pumpWidget(createTestWidget());

      await tester.pumpAndSettle();

      // Find and tap Contact Support
      await tester.tap(find.text('Contact Support'));
      await tester.pumpAndSettle();

      // Verify contact support dialog is displayed
      expect(find.text('Contact Support'),
          findsWidgets); // Allow multiple instances
      expect(find.text('Subject'), findsOneWidget);
      expect(find.text('Message'), findsOneWidget);
      expect(find.text('SEND'), findsOneWidget);
    });

    testWidgets('should show logout confirmation dialog',
        (WidgetTester tester) async {
      setupLargeTestSurface(tester);
      await tester.pumpWidget(createTestWidget());

      await tester.pumpAndSettle();

      // Find and tap logout button
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      // Verify logout confirmation dialog
      expect(find.text('Logout'), findsWidgets); // Allow multiple instances
      expect(find.text('Are you sure you want to logout?'), findsOneWidget);
      expect(find.text('CANCEL'), findsOneWidget);
      expect(find.text('LOGOUT'), findsOneWidget);
    });

    testWidgets('should validate form inputs in edit profile dialog',
        (WidgetTester tester) async {
      setupLargeTestSurface(tester);
      await tester.pumpWidget(createTestWidget());

      await tester.pumpAndSettle();

      // Open edit profile dialog
      final editButtons = find.byIcon(Icons.edit);
      await tester.tap(editButtons.first);
      await tester.pumpAndSettle();

      // Find form fields
      final nameField = find.byType(TextFormField).at(0);
      final emailField = find.byType(TextFormField).at(1);

      // Clear name field and try to save
      await tester.enterText(nameField, '');
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      // Verify validation error
      expect(find.text('Please enter your name'), findsOneWidget);

      // Enter invalid email
      await tester.enterText(emailField, 'invalid-email');
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      // Verify email validation error
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('should show vehicle edit dialog', (WidgetTester tester) async {
      setupLargeTestSurface(tester);
      await tester.pumpWidget(createTestWidget());

      await tester.pumpAndSettle();

      // Find and tap vehicle details
      await tester.tap(find.text('Vehicle Details'));
      await tester.pumpAndSettle();

      // Verify vehicle edit dialog
      expect(find.text('Edit Vehicle Information'), findsOneWidget);
      expect(find.text('Vehicle Make'), findsOneWidget);
      expect(find.text('Vehicle Model'), findsOneWidget);
      expect(find.text('Vehicle Color'), findsOneWidget);
      expect(find.text('License Plate'), findsOneWidget);
    });

    testWidgets('should show payment methods dialog',
        (WidgetTester tester) async {
      setupLargeTestSurface(tester);
      await tester.pumpWidget(createTestWidget());

      await tester.pumpAndSettle();

      // Find and tap payment methods
      await tester.tap(find.text('Credit/Debit Cards'));
      await tester.pumpAndSettle();

      // Verify payment methods dialog (allow multiple instances of title)
      expect(find.text('Payment Methods'),
          findsWidgets); // Allow multiple instances
      expect(find.text('Visa **** 1234'), findsOneWidget);
      expect(find.text('MasterCard **** 5678'), findsOneWidget);
      expect(find.text('Add New Card'), findsOneWidget);
    });

    testWidgets('should show about dialog', (WidgetTester tester) async {
      setupLargeTestSurface(tester);
      await tester.pumpWidget(createTestWidget());

      await tester.pumpAndSettle();

      // Find and tap about
      await tester.tap(find.text('About ParkEase'));
      await tester.pumpAndSettle();

      // Verify about dialog
      expect(find.text('ParkEase'), findsWidgets); // Allow multiple instances
      expect(find.text('1.0.0'), findsOneWidget);
    });
  });

  group('ProfileScreenFixed Widget Tests', () {
    testWidgets('should create ProfileScreenFixed widget',
        (WidgetTester tester) async {
      const widget = ProfileScreenFixed();
      expect(widget, isA<StatefulWidget>());
    });

    testWidgets('should have correct key', (WidgetTester tester) async {
      const key = Key('profile_screen');
      const widget = ProfileScreenFixed(key: key);
      expect(widget.key, key);
    });
  });

  group('ProfileScreenFixed State Tests', () {
    testWidgets('should initialize with correct default values',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ProfileScreenFixed(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify default notification settings
      final switches =
          tester.widgetList<SwitchListTile>(find.byType(SwitchListTile));

      // Main notifications should be enabled by default
      expect(switches.first.value, true);
    });
  });
}
