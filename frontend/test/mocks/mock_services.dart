import 'package:mockito/annotations.dart';
import 'package:parkease/core/services/api_service.dart';
import 'package:parkease/core/services/auth_service.dart';
import 'package:parkease/core/services/location_service.dart';
import 'package:parkease/core/services/storage_service.dart';
import 'package:parkease/core/services/navigation_service.dart';

// Generate mocks for all services
@GenerateMocks([
  ApiService,
  AuthService,
  LocationService,
  StorageService,
  NavigationService,
])
void main() {}