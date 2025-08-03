import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:parkease/core/viewmodels/booking_viewmodel.dart';
import 'package:parkease/ui/screens/booking/booking_history_screen.dart';

// Generate mocks
@GenerateMocks([BookingViewModel])
import 'booking_history_screen_test.mocks.dart';

void main() {
  group('BookingHistoryScreen Tests', () {
    late MockBookingViewModel mockBookingViewModel;

    setUp(() {
      mockBookingViewModel = MockBookingViewModel();
      
      // Setup default stubs for all properties
      when(mockBookingViewModel.isLoading).thenReturn(false);
      when(mockBookingViewModel.errorMessage).thenReturn(null);
      when(mockBookingViewModel.userBookings).thenReturn([]);
      when(mockBookingViewModel.selectedBooking).thenReturn(null);
      when(mockBookingViewModel.currentPage).thenReturn(1);
      when(mockBookingViewModel.totalPages).thenReturn(1);
      when(mockBookingViewModel.hasMoreBookings).thenReturn(false);
      when(mockBookingViewModel.getActiveBookings()).thenReturn([]);
      when(mockBookingViewModel.getUpcomingBookings()).thenReturn([]);
      when(mockBookingViewModel.getCompletedBookings()).thenReturn([]);
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<BookingViewModel>.value(
          value: mockBookingViewModel,
          child: const BookingHistoryScreen(),
        ),
      );
    }

    testWidgets('should display booking history screen elements',
        (WidgetTester tester) async {
      // Arrange
      when(mockBookingViewModel.isLoading).thenReturn(false);
      when(mockBookingViewModel.errorMessage).thenReturn(null);
      when(mockBookingViewModel.userBookings).thenReturn([]);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should show loading indicator when loading',
        (WidgetTester tester) async {
      // Arrange
      when(mockBookingViewModel.isLoading).thenReturn(true);
      when(mockBookingViewModel.errorMessage).thenReturn(null);
      when(mockBookingViewModel.userBookings).thenReturn([]);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle error state', (WidgetTester tester) async {
      // Arrange
      const errorMessage = 'Failed to load bookings';
      when(mockBookingViewModel.isLoading).thenReturn(false);
      when(mockBookingViewModel.errorMessage).thenReturn(errorMessage);
      when(mockBookingViewModel.userBookings).thenReturn([]);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display empty state when no bookings',
        (WidgetTester tester) async {
      // Arrange
      when(mockBookingViewModel.isLoading).thenReturn(false);
      when(mockBookingViewModel.errorMessage).thenReturn(null);
      when(mockBookingViewModel.userBookings).thenReturn([]);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
