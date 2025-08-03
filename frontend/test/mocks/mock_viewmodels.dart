import 'package:mockito/annotations.dart';
import 'package:parkease/core/viewmodels/auth_viewmodel.dart';
import 'package:parkease/core/viewmodels/home_viewmodel.dart';
import 'package:parkease/core/viewmodels/map_viewmodel.dart';
import 'package:parkease/core/viewmodels/profile_viewmodel.dart';
import 'package:parkease/core/viewmodels/booking_viewmodel.dart';

// Generate mocks for all view models
@GenerateMocks([
  AuthViewModel,
  HomeViewModel,
  MapViewModel,
  ProfileViewModel,
  BookingViewModel,
])
void main() {}