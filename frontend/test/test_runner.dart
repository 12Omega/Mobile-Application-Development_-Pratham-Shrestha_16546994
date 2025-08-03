import 'package:flutter_test/flutter_test.dart';
import 'all_screens_test.dart' as all_screens;

void main() {
  group('ParkEase App Test Suite', () {
    setUpAll(() {
      // Global test setup
      print('🚀 Starting ParkEase App Test Suite...');
    });

    tearDownAll(() {
      // Global test cleanup
      print('✅ ParkEase App Test Suite completed!');
    });

    // Run all screen tests
    all_screens.main();
  });
}