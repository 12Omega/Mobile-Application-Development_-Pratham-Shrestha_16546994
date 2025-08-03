import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

// Data layer
import '../../data/remote/api_service.dart';
import '../../data/local/local_storage_service.dart';

// Services
import '../services/theme_service.dart';
import '../services/auth_service.dart';
import '../services/booking_service.dart';
import '../services/parking_service.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';
import '../services/navigation_service.dart';
import '../services/api_service.dart' as core_api;

// ViewModels
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/booking_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/map_viewmodel.dart';
import '../viewmodels/parking_viewmodel.dart';
import '../viewmodels/profile_viewmodel.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External dependencies
  sl.registerLazySingleton<http.Client>(() => http.Client());

  // Core Services - Initialize StorageService first
  final storageService = StorageService();
  await storageService.init();
  sl.registerLazySingleton<StorageService>(() => storageService);
  
  sl.registerLazySingleton<NavigationService>(() => NavigationService());
  sl.registerLazySingleton<core_api.ApiService>(() => core_api.ApiService());
  sl.registerLazySingleton<LocationService>(() => LocationService());
  sl.registerLazySingleton<ThemeService>(() => ThemeService());

  // Business Services
  sl.registerLazySingleton<AuthService>(() => AuthService(
    sl<core_api.ApiService>(),
    sl<StorageService>(),
  ));
  
  sl.registerLazySingleton<BookingService>(() => BookingService(
    sl<core_api.ApiService>(),
  ));
  
  sl.registerLazySingleton<ParkingService>(() => ParkingService(
    sl<core_api.ApiService>(),
  ));

  // ViewModels
  sl.registerFactory<AuthViewModel>(() => AuthViewModel(
    sl<AuthService>(),
    sl<StorageService>(),
    sl<NavigationService>(),
  ));

  sl.registerFactory<BookingViewModel>(() => BookingViewModel(
    sl<BookingService>(),
  ));

  sl.registerFactory<HomeViewModel>(() => HomeViewModel(
    sl<AuthService>(),
    sl<ParkingService>(),
    sl<BookingService>(),
    sl<LocationService>(),
  ));

  sl.registerFactory<MapViewModel>(() => MapViewModel(
    sl<LocationService>(),
    sl<ParkingService>(),
  ));

  sl.registerFactory<ParkingViewModel>(() => ParkingViewModel(
    sl<ParkingService>(),
    sl<LocationService>(),
  ));

  sl.registerFactory<ProfileViewModel>(() => ProfileViewModel(
    sl<AuthService>(),
    sl<BookingService>(),
    sl<StorageService>(),
    sl<core_api.ApiService>(),
  ));

  // Data layer (for backward compatibility)
  sl.registerLazySingleton<ApiService>(
    () => ApiServiceImpl(client: sl<http.Client>()),
  );

  sl.registerLazySingleton<LocalStorageService>(
    () => LocalStorageServiceImpl(),
  );
}
