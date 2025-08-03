import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/di/service_locator.dart';
import 'package:parkease/core/services/theme_service.dart';
import 'package:parkease/core/viewmodels/auth_viewmodel.dart';
import 'package:parkease/core/viewmodels/booking_viewmodel.dart';
import 'package:parkease/core/viewmodels/home_viewmodel.dart';
import 'package:parkease/core/viewmodels/map_viewmodel.dart';
import 'package:parkease/core/viewmodels/parking_viewmodel.dart';
import 'package:parkease/core/viewmodels/profile_viewmodel.dart';
import 'package:parkease/ui/router.dart';
import 'package:parkease/ui/shared/app_theme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Setup dependency injection
  await setupServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        ChangeNotifierProvider(create: (_) => sl<ThemeService>()),

        // ViewModels
        ChangeNotifierProvider(create: (_) => sl<AuthViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<ParkingViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<BookingViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<HomeViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<MapViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<ProfileViewModel>()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, _) {
          return MaterialApp.router(
            title: 'ParkEase',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeService.themeMode,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
