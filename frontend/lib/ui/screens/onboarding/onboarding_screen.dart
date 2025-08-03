import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:parkease/core/services/storage_service.dart';
import 'package:parkease/ui/router.dart';
import 'package:parkease/ui/shared/app_theme.dart';
import 'package:parkease/core/di/service_locator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Find Parking Spots',
      description:
          'Locate available parking spots in real-time near your destination',
      animationAsset: 'assets/animations/map_search.json',
      backgroundColor: AppTheme.primaryColor,
    ),
    OnboardingPage(
      title: 'Reserve & Pay',
      description:
          'Reserve your spot in advance and pay securely through the app',
      animationAsset: 'assets/animations/payment.json',
      backgroundColor: const Color(0xFF22C55E),
    ),
    OnboardingPage(
      title: 'Navigate & Park',
      description: 'Get directions to your spot and enjoy hassle-free parking',
      animationAsset: 'assets/animations/navigation.json',
      backgroundColor: const Color(0xFF3B82F6),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    final storageService = sl<StorageService>();
    await storageService.setHasCompletedOnboarding(true);

    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page view
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final page = _pages[index];
              return _buildPage(page);
            },
          ),

          // Skip button
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: _completeOnboarding,
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Bottom navigation
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Page indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => _buildPageIndicator(index == _currentPage),
                  ),
                ),

                const SizedBox(height: 40),

                // Next/Get Started button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _pages[_currentPage].backgroundColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Container(
      color: page.backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 80),

          // Animation
          SizedBox(
            height: 300,
            child: Lottie.asset(
              page.animationAsset,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 40),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              page.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 16),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              page.description,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: isActive ? 12 : 8,
      width: isActive ? 12 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String animationAsset;
  final Color backgroundColor;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.animationAsset,
    required this.backgroundColor,
  });
}
