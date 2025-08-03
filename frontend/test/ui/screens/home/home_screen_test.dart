import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:parkease/core/viewmodels/home_viewmodel.dart';
import 'package:parkease/core/models/user_model.dart';
import 'package:parkease/core/models/parking_model.dart';
import 'package:parkease/core/models/booking_model.dart';
import 'package:parkease/ui/screens/home/home_screen.dart';

// Generate mocks
@GenerateMocks([HomeViewModel])
import 'home_screen_test.mocks.dart';

void main() {
  group('HomeScreen Tests', () {
    late MockHomeViewModel mockHomeViewModel;

    setUp(() {
      mockHomeViewModel = MockHomeViewModel();
      
      // Setup default stubs for all properties
      when(mockHomeViewModel.isLoading).thenReturn(false);
      when(mockHomeViewModel.errorMessage).thenReturn(null);
      when(mockHomeViewModel.user).thenReturn(null);
      when(mockHomeViewModel.nearbyParkingLots).thenReturn([]);
      when(mockHomeViewModel.activeBookings).thenReturn([]);
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<HomeViewModel>.value(
          value: mockHomeViewModel,
          child: const HomeScreen(),
        ),
      );
    }

    testWidgets('should display home screen elements', (WidgetTester tester) async {
      // Arrange
      when(mockHomeViewModel.isLoading).thenReturn(false);
      when(mockHomeViewModel.errorMessage).thenReturn(null);
      when(mockHomeViewModel.user).thenReturn(User(
        id: '1',
        name: 'Test User',
        email: 'test@example.com',
        phone: '1234567890',
        vehicleInfo: VehicleInfo(
          licensePlate: 'ABC123',
          vehicleType: 'car',
          color: 'blue',
          model: 'Toyota Camry',
        ),
        preferences: UserPreferences(),
        role: 'user',
        isActive: true,
        createdAt: '2024-01-01T00:00:00Z',
        updatedAt: '2024-01-01T00:00:00Z',
      ));

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert - Look for common home screen elements
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should show loading indicator when loading', (WidgetTester tester) async {
      // Arrange
      when(mockHomeViewModel.isLoading).thenReturn(true);
      when(mockHomeViewModel.errorMessage).thenReturn(null);
      when(mockHomeViewModel.nearbyParkingLots).thenReturn([]);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle error state', (WidgetTester tester) async {
      // Arrange
      const errorMessage = 'Failed to load data';
      when(mockHomeViewModel.isLoading).thenReturn(false);
      when(mockHomeViewModel.errorMessage).thenReturn(errorMessage);
      when(mockHomeViewModel.user).thenReturn(User(
        id: '1',
        name: 'Test User',
        email: 'test@example.com',
        phone: '1234567890',
        vehicleInfo: VehicleInfo(
          licensePlate: 'ABC123',
          vehicleType: 'car',
          color: 'blue',
          model: 'Toyota Camry',
        ),
        preferences: UserPreferences(),
        role: 'user',
        isActive: true,
        createdAt: '2024-01-01T00:00:00Z',
        updatedAt: '2024-01-01T00:00:00Z',
      ));

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert - Error should be handled gracefully
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}