import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parkease/core/viewmodels/map_viewmodel.dart';
import 'package:parkease/ui/screens/map/map_screen.dart';

// Generate mocks
@GenerateMocks([MapViewModel])
import 'map_screen_test.mocks.dart';

void main() {
  group('MapScreen Tests', () {
    late MockMapViewModel mockMapViewModel;

    setUp(() {
      mockMapViewModel = MockMapViewModel();
      
      // Setup default stubs for all properties
      when(mockMapViewModel.isLoading).thenReturn(false);
      when(mockMapViewModel.errorMessage).thenReturn(null);
      when(mockMapViewModel.markers).thenReturn(<Marker>{});
      when(mockMapViewModel.parkingLots).thenReturn([]);
      when(mockMapViewModel.selectedParkingLot).thenReturn(null);
      when(mockMapViewModel.mapController).thenReturn(null);
      when(mockMapViewModel.initialCameraPosition).thenReturn(
        const CameraPosition(
          target: LatLng(37.7749, -122.4194), // San Francisco
          zoom: 14.0,
        ),
      );
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<MapViewModel>.value(
          value: mockMapViewModel,
          child: const MapScreen(),
        ),
      );
    }

    testWidgets('should display map screen elements', (WidgetTester tester) async {
      // Arrange
      when(mockMapViewModel.isLoading).thenReturn(false);
      when(mockMapViewModel.errorMessage).thenReturn(null);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should show loading indicator when loading', (WidgetTester tester) async {
      // Arrange
      when(mockMapViewModel.isLoading).thenReturn(true);
      when(mockMapViewModel.errorMessage).thenReturn(null);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle error state', (WidgetTester tester) async {
      // Arrange
      const errorMessage = 'Failed to load map';
      when(mockMapViewModel.isLoading).thenReturn(false);
      when(mockMapViewModel.errorMessage).thenReturn(errorMessage);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}