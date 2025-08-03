import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core
import 'core/di/injection_container.dart' as di;

// Features - Profile
import 'features/profile/presentation/viewmodels/profile_viewmodel.dart';
import 'features/profile/presentation/screens/profile_screen_clean.dart';

// Shared
import 'shared/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  await di.init();
  
  runApp(const ParkEaseCleanApp());
}

class ParkEaseCleanApp extends StatelessWidget {
  const ParkEaseCleanApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParkEase - Clean Architecture',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const CleanArchitectureDemo(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CleanArchitectureDemo extends StatelessWidget {
  const CleanArchitectureDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clean Architecture Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ParkEase Clean Architecture',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Features implemented with Clean Architecture:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildFeatureButton(
              context,
              'Profile Feature',
              'View user profile with Clean Architecture',
              Icons.person,
              () => _navigateToProfile(context),
            ),
            const SizedBox(height: 16),
            _buildFeatureButton(
              context,
              'Auth Feature',
              'Coming soon...',
              Icons.login,
              null,
            ),
            const SizedBox(height: 16),
            _buildFeatureButton(
              context,
              'Parking Feature',
              'Coming soon...',
              Icons.local_parking,
              null,
            ),
            const SizedBox(height: 16),
            _buildFeatureButton(
              context,
              'Booking Feature',
              'Coming soon...',
              Icons.book_online,
              null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback? onPressed,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: onPressed != null
            ? const Icon(Icons.arrow_forward_ios)
            : const Icon(Icons.hourglass_empty, color: Colors.grey),
        onTap: onPressed,
        enabled: onPressed != null,
      ),
    );
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileScreenClean(
          userId: 'demo-user-123', // In real app, get from auth
        ),
      ),
    );
  }
}

// Example of how to provide ViewModels at app level
class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Profile Feature
        ChangeNotifierProvider<ProfileViewModel>(
          create: (_) => di.sl<ProfileViewModel>(),
        ),
        
        // Add other feature ViewModels here as you migrate them
        // ChangeNotifierProvider<AuthViewModel>(
        //   create: (_) => di.sl<AuthViewModel>(),
        // ),
        // ChangeNotifierProvider<ParkingViewModel>(
        //   create: (_) => di.sl<ParkingViewModel>(),
        // ),
      ],
      child: child,
    );
  }
}