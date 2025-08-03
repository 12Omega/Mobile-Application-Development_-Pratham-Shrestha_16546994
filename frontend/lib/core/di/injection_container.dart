import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// Core
import '../network/api_client.dart';
import '../network/network_info.dart';
import '../storage/local_storage.dart';

// Features - Profile
import '../../features/profile/data/datasources/profile_local_datasource.dart';
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_user_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_user_profile_usecase.dart';
import '../../features/profile/presentation/viewmodels/profile_viewmodel.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Profile
  // ViewModels
  sl.registerFactory(
    () => ProfileViewModel(
      getUserProfileUseCase: sl(),
      updateUserProfileUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserProfileUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(apiClient: sl()),
  );

  sl.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(localStorage: sl()),
  );

  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<LocalStorage>(
    () => LocalStorageImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton(
    () => ApiClient(
      baseUrl: 'https://your-api-base-url.com/api/v1',
    ),
  );

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => Connectivity());
}