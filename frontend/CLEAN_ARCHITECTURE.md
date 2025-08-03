# Clean Architecture Implementation

This document explains the Clean Architecture implementation for the ParkEase Flutter app.

## Architecture Overview

The app follows Clean Architecture principles with three main layers:

### 1. Presentation Layer (`presentation/`)

- **ViewModels**: Handle UI state and business logic coordination
- **Screens**: UI components that display data and handle user interactions
- **Widgets**: Reusable UI components

### 2. Domain Layer (`domain/`)

- **Entities**: Core business objects (pure Dart classes)
- **Repositories**: Abstract interfaces for data operations
- **Use Cases**: Single-purpose business logic operations

### 3. Data Layer (`data/`)

- **Models/DTOs**: Data transfer objects for API/database
- **Repositories**: Concrete implementations of domain repositories
- **Data Sources**: Remote (API) and Local (cache/database) data sources

## Project Structure

```
lib/
├── features/                    # Feature-based organization
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/         # DTOs for auth
│   │   │   ├── repositories/   # Repository implementations
│   │   │   └── datasources/    # Remote & local data sources
│   │   ├── domain/
│   │   │   ├── entities/       # Core auth entities
│   │   │   ├── repositories/   # Repository interfaces
│   │   │   └── usecases/       # Auth use cases
│   │   └── presentation/
│   │       ├── viewmodels/     # Auth view models
│   │       └── screens/        # Auth screens
│   ├── profile/
│   ├── parking/
│   └── booking/
├── core/                       # Shared core functionality
│   ├── di/                     # Dependency injection
│   ├── error/                  # Error handling
│   ├── network/                # Network utilities
│   ├── storage/                # Local storage
│   ├── usecases/               # Base use case classes
│   └── utils/                  # Utilities
├── shared/                     # Shared UI components
│   ├── widgets/                # Reusable widgets
│   ├── theme/                  # App theming
│   └── utils/                  # UI utilities
└── main.dart
```

## Key Principles

### 1. Dependency Inversion

- High-level modules don't depend on low-level modules
- Both depend on abstractions (interfaces)
- Dependencies flow inward toward the domain layer

### 2. Single Responsibility

- Each class has one reason to change
- Use cases handle single business operations
- ViewModels manage single screen states

### 3. Interface Segregation

- Clients don't depend on interfaces they don't use
- Small, focused repository interfaces
- Specific data source contracts

### 4. Open/Closed Principle

- Open for extension, closed for modification
- Easy to add new features without changing existing code
- Plugin architecture for data sources

## Data Flow

```
UI → ViewModel → UseCase → Repository → DataSource → API/Database
                    ↓
                 Entity ← DTO/Model
```

1. **UI** triggers actions through **ViewModel**
2. **ViewModel** calls appropriate **UseCase**
3. **UseCase** executes business logic using **Repository**
4. **Repository** coordinates between **Remote** and **Local** data sources
5. **DataSource** fetches data and converts **DTOs** to **Entities**
6. **Entities** flow back through the layers to the **UI**

## Error Handling

### Failures vs Exceptions

- **Exceptions**: Technical errors (network, parsing, etc.)
- **Failures**: Business logic errors returned to UI

### Either Pattern

Using `dartz` package for functional error handling:

```dart
Future<Either<Failure, Entity>> someOperation();
```

## Testing Strategy

### Unit Tests

- **Use Cases**: Test business logic in isolation
- **Repositories**: Test data coordination logic
- **ViewModels**: Test state management

### Integration Tests

- **Data Sources**: Test API integration
- **Repository Implementations**: Test data flow

### Widget Tests

- **Screens**: Test UI behavior
- **Widgets**: Test component functionality

## Dependencies

### Core Dependencies

- `dartz`: Functional programming (Either, Option)
- `equatable`: Value equality for entities
- `get_it`: Dependency injection
- `connectivity_plus`: Network connectivity

### Data Layer

- `http`: HTTP client
- `shared_preferences`: Local storage
- `json_annotation`: JSON serialization

### Presentation Layer

- `provider`: State management
- `flutter_bloc`: Alternative state management (if needed)

## Usage Examples

### Creating a New Feature

1. **Define Entity** (Domain Layer)

```dart
class User extends Equatable {
  final String id;
  final String name;
  final String email;

  const User({required this.id, required this.name, required this.email});

  @override
  List<Object> get props => [id, name, email];
}
```

2. **Define Repository Interface** (Domain Layer)

```dart
abstract class UserRepository {
  Future<Either<Failure, User>> getUser(String id);
  Future<Either<Failure, User>> updateUser(User user);
}
```

3. **Create Use Case** (Domain Layer)

```dart
class GetUserUseCase implements UseCase<User, String> {
  final UserRepository repository;

  GetUserUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(String userId) {
    return repository.getUser(userId);
  }
}
```

4. **Implement Repository** (Data Layer)

```dart
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> getUser(String id) async {
    try {
      final userDto = await remoteDataSource.getUser(id);
      await localDataSource.cacheUser(userDto);
      return Right(userDto.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
```

5. **Create ViewModel** (Presentation Layer)

```dart
class UserViewModel extends ChangeNotifier {
  final GetUserUseCase getUserUseCase;

  UserViewModel({required this.getUserUseCase});

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters and methods...

  Future<void> loadUser(String userId) async {
    _isLoading = true;
    notifyListeners();

    final result = await getUserUseCase(userId);
    result.fold(
      (failure) => _errorMessage = failure.message,
      (user) => _user = user,
    );

    _isLoading = false;
    notifyListeners();
  }
}
```

## Migration Guide

To migrate existing code to Clean Architecture:

1. **Extract Entities**: Move business objects to `domain/entities/`
2. **Create Repository Interfaces**: Define contracts in `domain/repositories/`
3. **Implement Use Cases**: Move business logic to `domain/usecases/`
4. **Refactor Data Layer**: Separate DTOs, data sources, and repository implementations
5. **Update ViewModels**: Use use cases instead of direct service calls
6. **Setup Dependency Injection**: Configure all dependencies in `core/di/`

## Benefits

- **Testability**: Easy to unit test business logic
- **Maintainability**: Clear separation of concerns
- **Scalability**: Easy to add new features
- **Flexibility**: Easy to change data sources or UI frameworks
- **Team Collaboration**: Clear boundaries for different team members
