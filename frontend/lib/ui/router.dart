import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parkease/core/services/navigation_service.dart';
import 'package:parkease/core/services/storage_service.dart';
import 'package:get_it/get_it.dart';
import 'package:parkease/ui/screens/auth/login_screen.dart';
import 'package:parkease/ui/screens/auth/register_screen.dart';
import 'package:parkease/ui/screens/booking/booking_details_screen.dart';
import 'package:parkease/ui/screens/booking/booking_history_screen.dart';
import 'package:parkease/ui/screens/booking/create_booking_screen.dart';
import 'package:parkease/ui/screens/home/home_screen.dart';
import 'package:parkease/ui/screens/map/alternative_map_screen.dart';
import 'package:parkease/ui/screens/onboarding/onboarding_screen.dart';
import 'package:parkease/ui/screens/parking/parking_details_screen.dart';
import 'package:parkease/ui/screens/profile/profile_screen.dart';
import 'package:parkease/ui/screens/profile/edit_profile_screen.dart';
import 'package:parkease/ui/screens/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String map = '/map';
  static const String parkingDetails = '/parking/:id';
  static const String createBooking = '/booking/create';
  static const String bookingDetails = '/booking/:id';
  static const String bookingHistory = '/bookings';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
}

StorageService get _storageService => GetIt.instance<StorageService>();

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoutes.splash,
    redirect: _handleRedirect,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.map,
        builder: (context, state) => const AlternativeMapScreen(),
      ),
      GoRoute(
        path: '/parking/:id',
        builder: (context, state) {
          final parkingId = state.pathParameters['id'] ?? '';
          return ParkingDetailsScreen(parkingId: parkingId);
        },
      ),
      GoRoute(
        path: AppRoutes.createBooking,
        builder: (context, state) {
          final parkingId = state.uri.queryParameters['parkingId'];
          final spotNumber = state.uri.queryParameters['spotNumber'];
          return CreateBookingScreen(
            parkingId: parkingId,
            spotNumber: spotNumber,
          );
        },
      ),
      GoRoute(
        path: '/booking/:id',
        builder: (context, state) {
          final bookingId = state.pathParameters['id'] ?? '';
          return BookingDetailsScreen(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: AppRoutes.bookingHistory,
        builder: (context, state) => const BookingHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
    ],
  );

  static Future<String?> _handleRedirect(
      BuildContext context, GoRouterState state) async {
    // Check if the user is logged in
    final token = await _storageService.getAuthToken();
    final isLoggedIn = token != null && token.isNotEmpty;

    // Check if the user has completed onboarding
    final hasCompletedOnboarding = await getHasCompletedOnboarding();

    // If the user is on the splash screen, let them stay there
    if (state.matchedLocation == AppRoutes.splash) {
      return null;
    }

    // If the user hasn't completed onboarding and isn't on the onboarding screen,
    // redirect them to the onboarding screen
    if (!hasCompletedOnboarding &&
        state.matchedLocation != AppRoutes.onboarding) {
      return AppRoutes.onboarding;
    }

    // If the user is logged in and trying to access auth screens,
    // redirect them to the home screen
    if (isLoggedIn &&
        (state.matchedLocation == AppRoutes.login ||
            state.matchedLocation == AppRoutes.register ||
            state.matchedLocation == AppRoutes.onboarding)) {
      return AppRoutes.home;
    }

    // If the user is not logged in and trying to access protected screens,
    // redirect them to the login screen
    if (!isLoggedIn &&
        state.matchedLocation != AppRoutes.login &&
        state.matchedLocation != AppRoutes.register &&
        state.matchedLocation != AppRoutes.onboarding) {
      return AppRoutes.login;
    }

    // Allow the user to continue to their destination
    return null;
  }

  static Future<bool> getHasCompletedOnboarding() async {
    return await _storageService.getBool('has_completed_onboarding') ?? false;
  }
}

extension StorageServiceExtension on StorageService {
  Future<bool> getHasCompletedOnboarding() async {
    return await getBool('has_completed_onboarding') ?? false;
  }

  Future<void> setHasCompletedOnboarding(bool value) async {
    await setBool('has_completed_onboarding', value);
  }
}
