import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:parkease/core/viewmodels/auth_viewmodel.dart';
import 'package:parkease/core/services/navigation_service.dart';
import 'package:parkease/ui/screens/auth/login_screen.dart';

// Generate mocks
@GenerateMocks([AuthViewModel, NavigationService])
import 'login_screen_test.mocks.dart';

void main() {
  group('LoginScreen Tests', () {
    late MockAuthViewModel mockAuthViewModel;

    setUp(() {
      mockAuthViewModel = MockAuthViewModel();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<AuthViewModel>.value(
          value: mockAuthViewModel,
          child: const LoginScreen(),
        ),
      );
    }

    testWidgets('should display login form elements',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthViewModel.isLoading).thenReturn(false);
      when(mockAuthViewModel.errorMessage).thenReturn(null);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in to continue to ParkEase'), findsOneWidget);
      expect(find.byType(TextFormField),
          findsNWidgets(2)); // Email and password fields
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Remember me'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);
    });

    testWidgets('should show error message when login fails',
        (WidgetTester tester) async {
      // Arrange
      const errorMessage = 'Invalid credentials';
      when(mockAuthViewModel.isLoading).thenReturn(false);
      when(mockAuthViewModel.errorMessage).thenReturn(errorMessage);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('should show loading indicator when logging in',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthViewModel.isLoading).thenReturn(true);
      when(mockAuthViewModel.errorMessage).thenReturn(null);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should validate email field', (WidgetTester tester) async {
      // Arrange
      when(mockAuthViewModel.isLoading).thenReturn(false);
      when(mockAuthViewModel.errorMessage).thenReturn(null);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('should validate password field', (WidgetTester tester) async {
      // Arrange
      when(mockAuthViewModel.isLoading).thenReturn(false);
      when(mockAuthViewModel.errorMessage).thenReturn(null);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Leave password field empty
      await tester.enterText(
          find.byType(TextFormField).first, 'test@example.com');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('should toggle password visibility',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthViewModel.isLoading).thenReturn(false);
      when(mockAuthViewModel.errorMessage).thenReturn(null);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find password field and visibility toggle
      final visibilityToggle = find.byIcon(Icons.visibility_outlined);

      // Verify visibility toggle exists
      expect(visibilityToggle, findsOneWidget);

      // Tap visibility toggle
      await tester.tap(visibilityToggle);
      await tester.pumpAndSettle();

      // Verify the icon changes after toggle
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('should show forgot password dialog',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthViewModel.isLoading).thenReturn(false);
      when(mockAuthViewModel.errorMessage).thenReturn(null);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap forgot password
      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Forgot Password'), findsOneWidget);
      expect(
          find.text('Please enter your email to receive reset instructions.'),
          findsOneWidget);
      expect(find.text('Send'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });
  });
}
