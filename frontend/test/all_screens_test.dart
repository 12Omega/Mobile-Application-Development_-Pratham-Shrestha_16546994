import 'package:flutter_test/flutter_test.dart';

// Import all screen tests
import 'ui/screens/auth/login_screen_test.dart' as login_tests;
import 'ui/screens/home/home_screen_test.dart' as home_tests;
import 'ui/screens/map/map_screen_test.dart' as map_tests;
import 'ui/screens/booking/booking_history_screen_test.dart' as booking_tests;
import 'ui/screens/profile/profile_screen_fixed_test.dart' as profile_tests;
import 'ui/screens/splash_screen_test.dart' as splash_tests;

void main() {
  group('All Screens Test Suite', () {
    group('Authentication Screens', () {
      login_tests.main();
    });

    group('Home Screen', () {
      home_tests.main();
    });

    group('Map Screen', () {
      map_tests.main();
    });

    group('Booking Screens', () {
      booking_tests.main();
    });

    group('Profile Screens', () {
      profile_tests.main();
    });

    group('Splash Screen', () {
      splash_tests.main();
    });
  });
}