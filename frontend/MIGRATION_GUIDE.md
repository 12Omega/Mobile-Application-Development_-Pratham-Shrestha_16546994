# Migration Guide: Converting to Clean Architecture

This guide shows how to migrate your existing ParkEase screens to the new Clean Architecture pattern.

## Example: Profile Screen Migration

### Before (Current Structure)
```
lib/
├── core/
│   ├── models/user_model.dart
│   ├── services/profile_service.dart
│   └── viewmodels/profile_viewmodel.dart
└── ui/
    └── screens/profile/profile_screen.dart
```

### After (Clean Architecture)
```
lib/
├── features/profile/
│   ├── domain/
│   │   ├── entities/user_profile.dart
│   │   ├── repositories/profile_repository.dart
│   │   └── usecases/get_user_profile_usecase.dart
│   ├── data/
│   │   ├── models/user_profile_dto.dart
│   │   ├── datasources/profile_remote_datasource.dart
│   │   └── repositories/profile_repository_impl.dart
│   └── presentation/
│       ├── viewmodels/profile_viewmodel.dart
│       └── screens/profile_screen_clean.dart
└── core/
    └── di/injection_container.dart
```

## Step-by-Step Migration

### Step 1: Extract Domain Entity

**Before** (`core/models/user_model.dart`):
```dart
class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  
  User({required this.id, required this.name, required this.email, required this.phone});
  
  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    phone: json['phone'],
  );
}
```

**After** (`features/profile/domain/entities/user_profile.dart`):
```dart
import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object> get props => [id, name, email, phone, createdAt, updatedAt];
}
```

### Step 2: Create Repository Interface

**New** (`features/profile/domain/repositories/profile_repository.dart`):
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile>> getUserProfile(String userId);
  Future<Either<Failure, UserProfile>> updateUserProfile(String userId, Map<String, dynamic> updateData);
}
```

### Step 3: Create Use Cases

**Before** (Business logic in ViewModel):
```dart
class ProfileViewModel extends ChangeNotifier {
  final ProfileService _profileService;
  
  Future<void> loadProfile() async {
    try {
      _user = await _profileService.getUserProfile();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
```

**After** (`features/profile/domain/usecases/get_user_profile_usecase.dart`):
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetUserProfileUseCase implements UseCase<UserProfile, String> {
  final ProfileRepository repository;

  GetUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(String userId) async {
    return await repository.getUserProfile(userId);
  }
}
```

### Step 4: Create Data Layer

**Before** (`core/services/profile_service.dart`):
```dart
class ProfileService {
  final ApiService _apiService;
  
  Future<User> getUserProfile() async {
    final response = await _apiService.get('/profile');
    return User.fromJson(response.data);
  }
}
```

**After** (`features/profile/data/datasources/profile_remote_datasource.dart`):
```dart
import '../models/user_profile_dto.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileDto> getUserProfile(String userId);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserProfileDto> getUserProfile(String userId) async {
    final response = await apiClient.get('/users/$userId/profile');
    return UserProfileDto.fromJson(json.decode(response.body)['data']);
  }
}
```

### Step 5: Update ViewModel

**Before**:
```dart
class ProfileViewModel extends ChangeNotifier {
  final ProfileService _profileService;
  User? _user;
  
  Future<void> loadProfile() async {
    try {
      _user = await _profileService.getUserProfile();
    } catch (e) {
      // Handle error
    }
    notifyListeners();
  }
}
```

**After**:
```dart
class ProfileViewModel extends ChangeNotifier {
  final GetUserProfileUseCase getUserProfileUseCase;
  UserProfile? _userProfile;
  
  Future<void> loadUserProfile(String userId) async {
    final result = await getUserProfileUseCase(userId);
    result.fold(
      (failure) => _setError(failure.message),
      (profile) => _setUserProfile(profile),
    );
  }
}
```

### Step 6: Update UI Screen

**Before**:
```dart
class ProfileScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        // Direct service calls
        viewModel.loadProfile();
        return Scaffold(/* ... */);
      },
    );
  }
}
```

**After**:
```dart
class ProfileScreenClean extends StatefulWidget {
  final String userId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<ProfileViewModel>(), // Dependency injection
      child: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          // Use cases handle business logic
          return Scaffold(/* ... */);
        },
      ),
    );
  }
}
```

### Step 7: Setup Dependency Injection

**New** (`core/di/injection_container.dart`):
```dart
final sl = GetIt.instance;

Future<void> init() async {
  // ViewModels
  sl.registerFactory(() => ProfileViewModel(
    getUserProfileUseCase: sl(),
    updateUserProfileUseCase: sl(),
  ));

  // Use cases
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  
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
}
```

## Migration Checklist

### For Each Feature:

- [ ] **Extract Domain Entities**
  - Move business objects from `models/` to `domain/entities/`
  - Remove JSON serialization (move to DTOs)
  - Add `Equatable` for value equality

- [ ] **Create Repository Interfaces**
  - Define contracts in `domain/repositories/`
  - Use `Either<Failure, Success>` return types
  - Keep interfaces focused and small

- [ ] **Implement Use Cases**
  - Move business logic from ViewModels to `domain/usecases/`
  - One use case per business operation
  - Implement `UseCase<ReturnType, Params>` interface

- [ ] **Refactor Data Layer**
  - Create DTOs in `data/models/`
  - Separate remote and local data sources
  - Implement repository with offline support

- [ ] **Update ViewModels**
  - Inject use cases instead of services
  - Handle `Either` results with `fold()`
  - Focus on UI state management only

- [ ] **Update UI Screens**
  - Use dependency injection (`sl<ViewModel>()`)
  - Remove direct service dependencies
  - Handle loading/error states consistently

- [ ] **Setup Dependencies**
  - Register all dependencies in `injection_container.dart`
  - Follow dependency flow: UI → Domain ← Data
  - Use appropriate registration types (factory/singleton)

### Testing Strategy:

- [ ] **Unit Tests for Use Cases**
  - Test business logic in isolation
  - Mock repository dependencies
  - Test both success and failure scenarios

- [ ] **Unit Tests for Repositories**
  - Test data coordination logic
  - Mock data sources and network info
  - Test offline/online scenarios

- [ ] **Unit Tests for ViewModels**
  - Test state management
  - Mock use case dependencies
  - Test UI state transitions

- [ ] **Integration Tests**
  - Test data source implementations
  - Test API integration
  - Test local storage operations

## Benefits After Migration

### ✅ **Testability**
- Easy to unit test business logic
- Clear mocking boundaries
- Isolated component testing

### ✅ **Maintainability**
- Clear separation of concerns
- Single responsibility principle
- Easy to locate and fix bugs

### ✅ **Scalability**
- Easy to add new features
- Consistent architecture patterns
- Team collaboration friendly

### ✅ **Flexibility**
- Easy to change data sources
- Platform-independent business logic
- Easy to add offline support

## Common Pitfalls to Avoid

### ❌ **Don't**
- Put business logic in ViewModels
- Make entities depend on external libraries
- Skip error handling with Either pattern
- Create circular dependencies
- Mix UI logic with business logic

### ✅ **Do**
- Keep entities pure Dart classes
- Use dependency injection consistently
- Handle all error scenarios
- Write tests for each layer
- Follow the dependency rule (inward dependencies only)

## Migration Timeline

### Phase 1: Setup Infrastructure (1-2 days)
- Setup core error handling
- Create base use case interface
- Setup dependency injection
- Add required dependencies

### Phase 2: Migrate One Feature (2-3 days)
- Choose simplest feature (e.g., Profile)
- Follow step-by-step migration
- Write comprehensive tests
- Document lessons learned

### Phase 3: Migrate Remaining Features (1-2 weeks)
- Apply learnings from Phase 2
- Migrate features in order of complexity
- Maintain backward compatibility during transition
- Update documentation

### Phase 4: Cleanup (2-3 days)
- Remove old architecture files
- Update imports and dependencies
- Final testing and optimization
- Team training and documentation

This migration approach ensures a smooth transition while maintaining app functionality throughout the process.