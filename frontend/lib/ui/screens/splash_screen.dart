import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:parkease/core/services/auth_service.dart';
import 'package:parkease/core/services/storage_service.dart';
import 'package:parkease/ui/router.dart';
import 'package:parkease/ui/shared/app_theme.dart';
import 'package:parkease/core/di/service_locator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Simulate loading time
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final storageService = sl<StorageService>();
    final authService = sl<AuthService>();

    // Check if user has completed onboarding
    final hasCompletedOnboarding =
        await storageService.getHasCompletedOnboarding();

    // Check if user is logged in
    final isLoggedIn = await authService.isLoggedIn();

    if (!mounted) return;

    if (!hasCompletedOnboarding) {
      context.go(AppRoutes.onboarding);
    } else if (!isLoggedIn) {
      context.go(AppRoutes.login);
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.local_parking_rounded,
                  size: 80,
                  color: AppTheme.primaryColor,
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(delay: 200.ms, duration: 500.ms),

            const SizedBox(height: 24),

            // App name
            Text(
              'ParkEase',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
            ).animate().fadeIn(delay: 400.ms, duration: 600.ms),

            const SizedBox(height: 8),

            // Tagline
            Text(
              'Smart Parking Solution',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
            ).animate().fadeIn(delay: 600.ms, duration: 600.ms),

            const SizedBox(height: 48),

            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ).animate().fadeIn(delay: 800.ms, duration: 600.ms),
          ],
        ),
      ),
    );
  }
}
